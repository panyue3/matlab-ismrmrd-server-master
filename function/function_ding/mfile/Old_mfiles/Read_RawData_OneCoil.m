% Try to read the raw data from the scanner
% function [Data, asc, prot] = Read_RawData(fname)
% This version solve the asc too large problem

function [Data, asc, prot] = Read_RawData_OneCoil(fname)
%function [Data, asc, prot, header] = Read_RawData(fname)
% asc(i).ushUsedChannels: Total # of channels, fixed
% asc(i).ushChannelId: Channel #

fid = fopen(fname);
L_P = fread(fid, 1, 'uint32');
prot = fread(fid, L_P-4, 'uint8');
% c0 = clock;
fseek(fid, 7*4,'cof');
Samples = fread(fid, 1, 'uint16');
STATUS = fseek(fid, 128-30,'cof');
STATUS = fseek(fid, 8*Samples + 4, 'cof');
i = 1;
while (STATUS+1)
    i = i + 1;
    fseek(fid, 7*4 - 4 ,'cof');
    Samples = fread(fid, 1, 'uint16');
    STATUS = fseek(fid, 128-30,'cof');
    STATUS = fseek(fid, 8*Samples + 4, 'cof'); % + 1 to test if it is end of the file
end
% The above is to detect the number of lines
N = i;
disp(['N = ', num2str(N)])
N = min([6.4*10^7, N]); % Ding 2011-08-20
disp(['N = min([6.4*10^6, N]) ', num2str(N) ])

ST = fseek(fid,0,-1); % "rewinds" the file.
disp(['fseek = ', num2str(ST)])
STATUS = fseek(fid, L_P, 'cof');
fseek(fid, 7*4,'cof');
Samples = fread(fid, 1, 'uint16');
STATUS = fseek(fid, -30,'cof');

asc0 = struct( ...
'ulFlagsAndDMALength',  uint32(0), ...
'lMeasUID', int32(0), ...
'ulScanCounter',  uint32(0),...
'ulTimeStamp',  uint32(0),...
'ulPMUTimeStamp',  uint32(0),...
'aulEvalInfoMask',  uint32(zeros(2,1)),...
'ushSamplesInScan',  uint16(0),...
'ushUsedChannels',  uint16(0),...
'sLC',  uint16(zeros(14,1)),...
'sCutOff',  single(0),...
'ushKSpaceCentreColumn',  uint16(0),...
'ushCoilSelect',  uint16(0),...
'fReadOutOffcentre',  single(0),...
'ulTimeSinceLastRF',  uint32(0),...
'ushKSpaceCentreLineNo',  uint16(0),...
'ushKSpaceCentrePartitionNo',  uint16(0),...
'aushIceProgramPara',  uint16(zeros(4,1)),...
'aushFreePara',  uint16(zeros(4,1)),...
'sSD',  uint16(zeros(14,1)),...
'ushChannelId',  uint16(0),...
'ushPTABPosNeg',  uint16(0) ...
);
asc = asc0;

%disp(size(Data))
%disp(size(asc))
k = 0;
for i=1:N
    %i = i + 1; % if mod(i,1000)==0, i=i,clock, end
    asc0.ulFlagsAndDMALength =        fread(fid, 1, 'uint32');
    asc0.lMeasUID =                   fread(fid, 1, 'int32');
    asc0.ulScanCounter =              fread(fid, 1, 'uint32');
    asc0.ulTimeStamp  =               fread(fid, 1, 'uint32');
    asc0.ulPMUTimeStamp =             fread(fid, 1, 'uint32');
    asc0.aulEvalInfoMask =            fread(fid, 2, 'uint32');
    asc0.ushSamplesInScan =           fread(fid, 1, 'uint16');
    asc0.ushUsedChannels =            fread(fid, 1, 'uint16'); % Channels % + 8 =8
    asc0.sLC =                        fread(fid, 14, 'uint16')'; % + 7 = 15
    asc0.sCutOff =                    fread(fid, 1, 'float'); % + 1 = 17
    asc0.ushKSpaceCentreColumn =      fread(fid, 1, 'uint16');
    asc0.ushCoilSelect =              fread(fid, 1, 'uint16');
    asc0.fReadOutOffcentre =          fread(fid, 1, 'float');
    asc0.ulTimeSinceLastRF =          fread(fid, 1, 'uint32'); % +3 = 19
    asc0.ushKSpaceCentreLineNo =      fread(fid, 1, 'uint16');
    asc0.ushKSpaceCentrePartitionNo = fread(fid, 1, 'uint16');
    asc0.aushIceProgramPara =         fread(fid, 4, 'uint16'); % + 3 = 22
    asc0.aushFreePara =               fread(fid, 4, 'uint16') ; % +2
    asc0.sSD =                        fread(fid, 14, 'uint16'); % + 7 = 31, No. 5 is No. of lines
    asc0.ushChannelId =               fread(fid, 1, 'uint16');
    asc0.ushPTABPosNeg =              fread(fid, 1, 'uint16'); % +1 = 32;
    t = 0; [t, count] =                 fread(fid, 2*asc0.ushSamplesInScan, 'float32');
    temp = asc0.sLC; Slice_Counter  = temp(3);
    if i == 1,
        N_ch = asc0.ushUsedChannels;
        asc = repmat(asc0,[1,N/N_ch]);
        Data = complex(single(zeros(Samples,N/N_ch, N_ch)), single(zeros(Samples,N/N_ch, N_ch)));
        N_counter = 1;
    end
    Data(1:asc0.ushSamplesInScan,N_counter, asc0.ushChannelId+1) = single(complex( t(1:2:end), t(2:2:end) ));
    if asc0.ushChannelId == N_ch - 1;
        asc(N_counter) = asc0;
        N_counter = N_counter + 1;
    end
    %if mod(k,10000)==0, k=k, end
    %if mod(i, 10000)==0, i=i, end
end
%disp(size(Data))
%disp(size(asc))
ST = fclose(fid);
disp(['fclose = ', num2str(ST)])




