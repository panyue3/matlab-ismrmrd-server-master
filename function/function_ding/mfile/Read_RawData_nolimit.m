% Try to read the raw data from the scanner
% function [Data, asc, prot] = Read_RawData(fname)

function [Data, asc, sLC, ushChannelId] = Read_RawData_nolimit(fname)
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
%N = min([6.4*10^5, N]); % Ding 2011-08-20, nolimit Ding 2015-10-07
%disp(['N = min([6.4*10^5, N]) ', num2str(N) ]) % nolimit Ding 2015-10-07

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

%asc = repmat(asc0,[1,N]);
Data = complex(single(zeros(Samples,N)), single(zeros(Samples,N)));
%disp(size(Data))
%disp(size(asc))
sLC = zeros(N, 14, 'uint16');
ushChannelId = zeros(N, 1, 'uint16');
k = 0;
for i=1:N
    %i = i + 1; % if mod(i,1000)==0, i=i,clock, end
    temp.ulFlagsAndDMALength =        fread(fid, 1, 'uint32');
    temp.lMeasUID =                   fread(fid, 1, 'int32');
    temp.ulScanCounter =              fread(fid, 1, 'uint32');
    temp.ulTimeStamp  =               fread(fid, 1, 'uint32');
    temp.ulPMUTimeStamp =             fread(fid, 1, 'uint32');
    temp.aulEvalInfoMask =            fread(fid, 2, 'uint32');
    temp.ushSamplesInScan =           fread(fid, 1, 'uint16');
    temp.ushUsedChannels =            fread(fid, 1, 'uint16'); % Channels % + 8 =8
    temp.sLC =                        fread(fid, 14, 'uint16')'; % + 7 = 15
    temp.sCutOff =                    fread(fid, 1, 'float'); % + 1 = 17
    temp.ushKSpaceCentreColumn =      fread(fid, 1, 'uint16');
    temp.ushCoilSelect =              fread(fid, 1, 'uint16');
    temp.fReadOutOffcentre =          fread(fid, 1, 'float');
    temp.ulTimeSinceLastRF =          fread(fid, 1, 'uint32'); % +3 = 19
    temp.ushKSpaceCentreLineNo =      fread(fid, 1, 'uint16');
    temp.ushKSpaceCentrePartitionNo = fread(fid, 1, 'uint16');
    temp.aushIceProgramPara =         fread(fid, 4, 'uint16'); % + 3 = 22
    temp.aushFreePara =               fread(fid, 4, 'uint16') ; % +2
    temp.sSD =                        fread(fid, 14, 'uint16'); % + 7 = 31, No. 5 is No. of lines
    temp.ushChannelId =               fread(fid, 1, 'uint16');
    temp.ushPTABPosNeg =              fread(fid, 1, 'uint16'); % +1 = 32;
    t = 0; [t, count] =                 fread(fid, 2*temp.ushSamplesInScan, 'float32');
    temp_sLC = temp.sLC; 
    Slice_Counter  = temp_sLC(3);
    Data(1:temp.ushSamplesInScan,i) = single(complex( t(1:2:end), t(2:2:end) ));
    if i == 1, asc = temp; end
    sLC(i, :) = temp_sLC;
    ushChannelId(i) = temp.ushChannelId;
    %if mod(i, 10000)==0, i=i, end
end
%disp(size(Data))
%disp(size(asc))
ST = fclose(fid);
disp(['fclose = ', num2str(ST)])




