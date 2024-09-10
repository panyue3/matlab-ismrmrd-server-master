% Try to read the write the raw data from the scanner
% function [Data, asc, prot] = Read_RawData_Slice(fname, varargin)

function [Data, asc, prot] = Read_RawData_Slice(fname, varargin)
%function [Data, asc, prot, header] = Read_RawData(fname)
% asc(i).ushUsedChannels: Total # of channels, fixed
% asc(i).ushChannelId: Channel #

if nargin==2
    option = varargin{1};
else
    option = int8(1);
end
Slice = option -1;
%option = option, isinteger(option)

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
N = i,

fseek(fid,0,-1); % "rewinds" the file.
STATUS = fseek(fid, L_P, 'cof');
fseek(fid, 7*4,'cof');
Samples = fread(fid, 1, 'uint16'),
STATUS = fseek(fid, -30,'cof');

asc0 = struct( ...
'ulFlagsAndDMALength',  0, ...
'lMeasUID', 0, ...
'ulScanCounter',  0,...
'ulTimeStamp',  0,...
'ulPMUTimeStamp',  0,...
'aulEvalInfoMask',  zeros(2,1),...
'ushSamplesInScan',  0,...
'ushUsedChannels',  0,...
'sLC',  zeros(14,1),...
'sCutOff',  0,...
'ushKSpaceCentreColumn',  0,...
'ushCoilSelect',  0,...
'fReadOutOffcentre',  0,...
'ulTimeSinceLastRF',  0,...
'ushKSpaceCentreLineNo',  0,...
'ushKSpaceCentrePartitionNo',  0,...
'aushIceProgramPara',  zeros(4,1),...
'aushFreePara',  zeros(4,1),...
'sSD',  zeros(14,1),...
'ushChannelId',  0,...
'ushPTABPosNeg',  0 ...
);
%n = min([N, 100000]); asc = repmat(asc0,1,n); % Old one 2010-09-08
n = N; asc = repmat(asc0,1,n); % New One 2010-09-08
Data = complex((zeros(Samples,n,'single')), (zeros(Samples,n,'single')));
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
    if Slice_Counter == Slice, 
        k = k + 1; 
        asc(k) = asc0;
        Data(1:asc0.ushSamplesInScan,k) = single(complex( t(1:2:end), t(2:2:end) ));
        %if mod(k,10000)==0, k=k, end
    end
    %if mod(i, 10000)==0, i=i, end
end
fclose(fid);
if k ==N,
else
    Data = Data(:,1:k);
end
asc = asc(1:k);
'End Read_RawData_Slice'
