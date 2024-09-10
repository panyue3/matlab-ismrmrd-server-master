function [rawdata,phasecor,feed_back,noise_scan, SO0, SO1, SO2, SO3, prescan] = Read_UIH_Raw_v5_2(filename)

fid = fopen(filename, 'rb');
% protocol length of in the file
offset = fread(fid,1,'uint32');
disp(['*** protocol length: ' num2str(offset)]);
fseek(fid,offset,'cof');

ACQFlag = 0;
NoiseScanIndex = 0;
DataFormat = 1;%1:DHL.m_ucVersion=1;2:DHL.m_ucVersion=2or3
TempNum = 0;

tic
%% check the dim size
maxROS = 1; maxCHA = 1; maxLNE = 0; maxSLC = 0; maxSPE = 0;
maxAVG = 0; maxREP = 0; maxCPH = 0; maxECO = 0; maxSET = 0;
maxUD0 = 0; maxUD1 = 0; maxUD2 = 0; maxUD3 = 0; maxUD4 = 0;
while(ACQFlag ~= 1)
    DHL = Read_UIH_DHL(fid);
    [DHLMask, flaglist] = DHLFlag(DHL.m_ullCtrlFlags);
    ACQFlag = DHLMask.DHL_ACQUISITION_END;
    
    %%%%%%%%%judge the rawdata version
    if(TempNum < 1)
        if(DHL.m_ucVersion == 1)
            DataFormat = 1;
            disp(['rawdata version : V1 ' ]);
        elseif(DHL.m_ucVersion == 2)
            DataFormat = 2;
            disp(['rawdata version : V2 ' ]);
        elseif(DHL.m_ucVersion == 3)
            DataFormat = 2;
            disp(['rawdata version : V3 ' ]);
        end
        TempNum = TempNum + 1;
    end
    
    %%%%%%%%%%find the max size of echo dimision
    if(~DHLMask.DHL_NOISE_SCAN & ~DHLMask.DHL_FEEDBACK)
%         if (maxROS<DHL.m_ushSamples)
        if (100<DHL.m_ushSamples && DHL.m_ushSamples<maxROS)
           maxUTEROS =  DHL.m_ushSamples;
        end
        maxROS = max(maxROS, DHL.m_ushSamples);
        maxCHA = max(maxCHA, DHL.m_ushUsedChannels);
        maxLNE = max(maxLNE, DHL.m_ushPELine);
        maxSPE = max(maxSPE, DHL.m_ushSPELine);
        maxSLC = max(maxSLC, DHL.m_ushSlice);
        maxAVG = max(maxAVG, DHL.m_ushAverage);
        maxREP = max(maxREP, DHL.m_ushRepeat);
        maxCPH = max(maxCPH, DHL.m_ushCardiacPhase);
        maxECO = max(maxECO, DHL.m_ushContrast);
        maxSET = max(maxSET, DHL.m_ushSet);
        maxUD0 = max(maxUD0, DHL.m_ushUser(1));
        maxUD1 = max(maxUD1, DHL.m_ushUser(2));
        maxUD2 = max(maxUD2, DHL.m_ushUser(3));
        maxUD3 = max(maxUD3, DHL.m_ushUser(4));
        maxUD4 = max(maxUD4, DHL.m_ushUser(5));
    end
    
    
    iSamples = DHL.m_ushSamples;
    iChannels = DHL.m_ushUsedChannels;
    if(DataFormat == 1)
        fseek(fid,(2*(iSamples)*iChannels)*4,'cof');
    elseif(DataFormat == 2)
        fseek(fid,(2*(iSamples+2)*iChannels)*4,'cof');
    end
        
end
rawdata_size=[maxLNE+1, maxSPE+1, maxSLC+1, maxAVG+1, maxREP+1,...
              maxCPH+1, maxECO+1, maxSET+1, maxUD0+1, maxUD1+1,...
              maxUD2+1, maxUD3+1, maxUD4+1, maxROS,   maxCHA,];
rawdata=zeros(rawdata_size);


% UTErawdata_size=[maxLNE+1, maxSPE+1, maxSLC+1, maxAVG+1, maxREP+1,...
%               maxCPH+1, 1, maxSET+1, maxUD0+1, maxUD1+1,...
%               maxUD2+1, maxUD3+1, maxUD4+1, maxUTEROS,   maxCHA,];
% UTErawdata=zeros(UTErawdata_size);
prescan=zeros(4,maxROS,maxCHA);
% UTEprescan=zeros(6,maxUTEROS,maxCHA);
prescancount=0;
uteprescancount=0;

% radialangle=zeros(1, (maxSPE+1) * (maxLNE+1));
SO0=zeros(1, (maxSPE+1) * (maxLNE+1));
SO1=zeros(1, (maxSPE+1) * (maxLNE+1));
SO2=zeros(1, (maxSPE+1) * (maxLNE+1));
SO3=zeros(1, (maxSPE+1) * (maxLNE+1));
radialanglecount=0;

%% read rawdata
fseek(fid,offset+4,'bof');
ACQFlag = 0;
while(ACQFlag ~= 1)
    DHL = Read_UIH_DHL(fid);
    [DHLMask, flaglist] = DHLFlag(DHL.m_ullCtrlFlags);
    ACQFlag = DHLMask.DHL_ACQUISITION_END;
    if (DHLMask.DHL_ACQUISITION_END == 1 )
        break;
    end
    %%%%%%%%%judge the receive gain----0:high gain;1:low gain
    ReceiveGain = 1;
    if(DHL.m_uReceiveGain == 1)
        ReceiveGain = 1.99;
    end
    %%%%%%%%%%%%%%%%
    Index = [DHL.m_ushRepeat+1,...
             DHL.m_ushCardiacPhase+1,...
             DHL.m_ushSlice+1,...
             DHL.m_ushAverage+1,...
             DHL.m_ushContrast+1,...
             DHL.m_ushSet+1,...
             DHL.m_ushPELine+1,...
             DHL.m_ushSPELine+1,...
             DHL.m_ushUser(1)+1,...
             DHL.m_ushUser(2)+1,...
             DHL.m_ushUser(3)+1,...
             DHL.m_ushUser(4)+1,...
             DHL.m_ushUser(5)+1];
        
    iSamples = DHL.m_ushSamples;
    iChannels = DHL.m_ushUsedChannels;
    %%%%%%%%%%%%%%%%
    if(DHLMask.DHL_NOISE_SCAN)
        NoiseScanIndex = NoiseScanIndex + 1;
        if(DataFormat == 1)
            LineData = ReadLineDataV1(fid,iSamples,iChannels);
        elseif(DataFormat == 2)
            LineData = ReadLineDataV2(fid,iSamples,iChannels);
        end
        LineData = LineData * ReceiveGain;
        noise_scan(:,:,NoiseScanIndex) = LineData(:,:);
    elseif(DHLMask.DHL_FEEDBACK)
        if(DataFormat == 1)
            LineData = ReadLineDataV1(fid,iSamples,iChannels);
        elseif(DataFormat == 2)
            LineData = ReadLineDataV2(fid,iSamples,iChannels);
        end
        LineData = LineData * ReceiveGain;
       feed_back(:,:,Index(1),Index(2),Index(3),Index(4),Index(5),Index(6),DHL.m_ushShot+1,...
                 Index(8),Index(9),Index(10),Index(11),Index(12),Index(13))...
                =LineData(:,:);
    elseif(DHLMask.DHL_PHASE_CORRECTION)
        if(DataFormat == 1)
            LineData = ReadLineDataV1(fid,iSamples,iChannels);
        elseif(DataFormat == 2)
            LineData = ReadLineDataV2(fid,iSamples,iChannels);
        end
        if(DHLMask.DHL_READOUT_REVERSION)
            LineData(1:1:end,:)=LineData(end:-1:1,:);
        end
        LineData = LineData * ReceiveGain;
        phasecor(:,:,Index(1),Index(2),Index(3),Index(4),Index(5),Index(6),DHL.m_ushSegment+1,...
                Index(8),Index(9),Index(10),Index(11),Index(12),Index(13))...
                =LineData(:,:);
    else    
        if(DataFormat == 1)
            LineData = ReadLineDataV1(fid,iSamples,iChannels);
        elseif(DataFormat == 2)
            LineData = ReadLineDataV2(fid,iSamples,iChannels);
        end        
        if(DHLMask.DHL_READOUT_REVERSION)
            LineData(1:1:end,:)=LineData(end:-1:1,:);
        end
        LineData = LineData * ReceiveGain;        
        
        if (length(LineData)==maxROS)
            rawdata(Index(7),Index(8),Index(3),Index(4),Index(1),Index(2),Index(5),...
                    Index(6),Index(9),Index(10),Index(11),Index(12),Index(13),:,:)...
            =LineData(:,:);

            prescancount=prescancount+1;
            if (prescancount<=4)
               prescan(prescancount,:,:) = LineData(:,:);
            end
            
%         elseif  (length(LineData)==maxUTEROS)
%             UTErawdata(Index(7),Index(8),Index(3),Index(4),Index(1),Index(2),Index(5),...
%                     Index(6),Index(9),Index(10),Index(11),Index(12),Index(13),:,:)...
%             =LineData(:,:); 
%         
%             uteprescancount=uteprescancount+1;
%             if (uteprescancount<=6)
%                UTEprescan(uteprescancount,:,:) = LineData(:,:);
%             end
        
            radialanglecount=radialanglecount+1;
            SO0(radialanglecount)=DHL.m_aflOrientation(1);
            SO1(radialanglecount)=DHL.m_aflOrientation(2);
            SO2(radialanglecount)=DHL.m_aflOrientation(3);
            SO3(radialanglecount)=DHL.m_aflOrientation(4);            
        end
    end
    
end
toc
fclose('all');

%% show
%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('noise_scan')
    noise_scan = 0;
else
%     sizenoisescan = size(noise_scan);
%     disp(['*** noise Size: ' ]);
%     disp(['Samples:          ' num2str(sizenoisescan(1))]);
%     disp(['UsedChannels:     ' num2str(sizenoisescan(2))]);
%     disp(['NoiseScanLines:   ' num2str(sizenoisescan(3))]);
end
if ~exist('phasecor')
    phasecor = 0;
else
%     sizephasecor = size(phasecor);
%     sizearrayphasecor = [sizephasecor,ones(1,15-size(sizephasecor,2))];
%     disp(['*** phasecor Size: ' ]);
%     disp(['Samples:          ' num2str(sizearrayphasecor(1))]);
%     disp(['UsedChannels:     ' num2str(sizearrayphasecor(2))]);
%     disp(['Repeat:           ' num2str(sizearrayphasecor(3))]);
%     disp(['CardiacPhase:     ' num2str(sizearrayphasecor(4))]);
%     disp(['Slice:            ' num2str(sizearrayphasecor(5))]);
%     disp(['Average:          ' num2str(sizearrayphasecor(6))]);
%     disp(['Contrast:         ' num2str(sizearrayphasecor(7))]);
%     disp(['Set:              ' num2str(sizearrayphasecor(8))]);
%     disp(['Segment:          ' num2str(sizearrayphasecor(9))]);
%     disp(['SPELine:          ' num2str(sizearrayphasecor(10))]);
%     disp(['UserDefine0:      ' num2str(sizearrayphasecor(11))]);
%     disp(['UserDefine1:      ' num2str(sizearrayphasecor(12))]);
%     disp(['UserDefine2:      ' num2str(sizearrayphasecor(13))]);
%     disp(['UserDefine3:      ' num2str(sizearrayphasecor(14))]);
%     disp(['UserDefine4:      ' num2str(sizearrayphasecor(15))]);
    phasecor = squeeze(phasecor);
end

if ~exist('feed_back')
    feed_back = 0;
else
%     sizefeed_back = size(feed_back);
%     sizearrayfeed_back = [sizefeed_back,ones(1,15-size(sizefeed_back,2))];
%     disp(['*** feed_back Size: ' ]);
%     disp(['Samples:          ' num2str(sizearrayfeed_back(1))]);
%     disp(['UsedChannels:     ' num2str(sizearrayfeed_back(2))]);
%     disp(['Repeat:           ' num2str(sizearrayfeed_back(3))]);
%     disp(['CardiacPhase:     ' num2str(sizearrayfeed_back(4))]);
%     disp(['Slice:            ' num2str(sizearrayfeed_back(5))]);
%     disp(['Average:          ' num2str(sizearrayfeed_back(6))]);
%     disp(['Contrast:         ' num2str(sizearrayfeed_back(7))]);
%     disp(['Set:              ' num2str(sizearrayfeed_back(8))]);
%     disp(['Shot:             ' num2str(sizearrayfeed_back(9))]);
%     disp(['SPELine:          ' num2str(sizearrayfeed_back(10))]);
%     disp(['UserDefine0:      ' num2str(sizearrayfeed_back(11))]);
%     disp(['UserDefine1:      ' num2str(sizearrayfeed_back(12))]);
%     disp(['UserDefine2:      ' num2str(sizearrayfeed_back(13))]);
%     disp(['UserDefine3:      ' num2str(sizearrayfeed_back(14))]);
%     disp(['UserDefine4:      ' num2str(sizearrayfeed_back(15))]);
    feed_back = squeeze(feed_back);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
sizerawdata = size(rawdata);
sizearray = [sizerawdata,ones(1,15-size(sizerawdata,2))];
disp(['***** Rawdata Size: ' ]);
disp(['Samples:          ' num2str(sizearray(14))]);
disp(['UsedChannels:     ' num2str(sizearray(15))]);
disp(['PELine:           ' num2str(sizearray(1))]);
disp(['SPELine:          ' num2str(sizearray(2))]);
disp(['Slice:            ' num2str(sizearray(3))]);
disp(['Average:          ' num2str(sizearray(4))]);
disp(['Repeat:           ' num2str(sizearray(5))]);
disp(['CardiacPhase:     ' num2str(sizearray(6))]);
disp(['Contrast:         ' num2str(sizearray(7))]);
disp(['Set:              ' num2str(sizearray(8))]);
disp(['UserDefine0:      ' num2str(sizearray(9))]);
disp(['UserDefine1:      ' num2str(sizearray(10))]);
disp(['UserDefine2:      ' num2str(sizearray(11))]);
disp(['UserDefine3:      ' num2str(sizearray(12))]);
disp(['UserDefine4:      ' num2str(sizearray(13))]);
rawdata = squeeze(rawdata);
size(rawdata)
% UTErawdata = squeeze(UTErawdata);



