% Try to write the raw data from the scanner
% function MSG = Write_RawData(fname, Data, asc, prot)


function MSG = Write_RawData(fname, Data, asc, prot)

fid = fopen(fname,'w');
L_P = length(prot) ;
fwrite(fid, L_P+4, 'uint32') ;
fwrite(fid, prot, 'uint8') ;
i = 0;
% t = fread(fid, 6, 'int32');         t=0; % skip 6 int32
% Samples = fread(fid, 1, 'uint16');  % Number of samples perline, this is the 1st
% Channels = fread(fid, 1, 'uint16'); % Number of channels
% skip = fread(fid, 38, 'uint16')';   % try where is the lines
% Lines = fread(fid, 1, 'uint16'),    % Numver of lines
% t = fread(fid, 11, 'uint16');t=0;   % Skip the rest 9 int16
% STATUS = fseek(fid, -128, 'cof');
% % Initialize the structure
% asc = struct( ...
% 'ulFlagsAndDMALength',  0, ...
% 'lMeasUID', 0, ...
% 'ulScanCounter',  0,...
% 'ulTimeStamp',  0,...
% 'ulPMUTimeStamp',  0,...
% 'aulEvalInfoMask',  0,...
% 'ushSamplesInScan',  0,...
% 'ushUsedChannels',  0,...
% 'sLC',  zeros(14,1), ...
% 'sCutOff',  0,...
% 'ushKSpaceCentreColumn',  0, ...
% 'ushCoilSelect',  0, ...
% 'fReadOutOffcentre',  0, ...
% 'ulTimeSinceLastRF',  0, ...
% 'ushKSpaceCentreLineNo',  0, ...
% 'ushKSpaceCentrePartitionNo',  0, ...
% 'aushIceProgramPara',  zeros(4,1), ...
% 'aushFreePara',  zeros(4,1), ...
% 'sSD',  zeros(14,1),...
% 'ushChannelId',  0,...
% 'ushPTABPosNeg',  0 ...
% );
% asc = repmat(asc,1,Channels*Lines);
% Data = zeros(Samples/2,Channels*Lines);
for i=1:length(asc)
    %if mod(i,1000)==0, i=i,clock, end
    fwrite(fid, asc(i).ulFlagsAndDMALength',             'uint32');
    fwrite(fid, asc(i).lMeasUID',                        'int32');
    fwrite(fid, asc(i).ulScanCounter',                   'uint32');
    fwrite(fid, asc(i).ulTimeStamp',                     'uint32');
    fwrite(fid, asc(i).ulPMUTimeStamp',                  'uint32');
    fwrite(fid, asc(i).aulEvalInfoMask' ,                'uint32');
    fwrite(fid, asc(i).ushSamplesInScan',                'uint16');
    fwrite(fid, asc(i).ushUsedChannels',                 'uint16');    % Channels % + 7 =7
    fwrite(fid, asc(i).sLC',                             'uint16')';  % + 7 = 14
    fwrite(fid, asc(i).sCutOff',                         'float');    % + 2 = 16
    fwrite(fid, asc(i).ushKSpaceCentreColumn',           'uint16');    
    fwrite(fid, asc(i).ushCoilSelect',                   'uint16');    
    fwrite(fid, asc(i).fReadOutOffcentre',               'float');     
    fwrite(fid, asc(i).ulTimeSinceLastRF',               'uint32');    % +3 = 19
    fwrite(fid, asc(i).ushKSpaceCentreLineNo',           'uint16');
    fwrite(fid, asc(i).ushKSpaceCentrePartitionNo',      'uint16');
    fwrite(fid, asc(i).aushIceProgramPara',              'uint16');    % + 3 = 22
    fwrite(fid, asc(i).aushFreePara',                    'uint16') ;   % + 2
    fwrite(fid, asc(i).sSD',                             'uint16');   % + 7 = 31, No. 5 is No. of lines
    fwrite(fid, asc(i).ushChannelId',                    'uint16');    
    fwrite(fid, asc(i).ushPTABPosNeg',                   'uint16');    % +1 = 32;
    temp = 0; t = 0;
    temp = Data(1:asc(i).ushSamplesInScan,i);
    %i=i,size(temp)
    t(1:2:2*asc(i).ushSamplesInScan) = real(temp);
    t(2:2:2*asc(i).ushSamplesInScan) = imag(temp);
    %Data(1:asc(i).ushSamplesInScan/2,i) = complex( t(1:2:end), t(1:2:end) );
    fwrite(fid, t,                                      'float32');
    
end
ST = fclose(fid);

if (ST+1), MSG = 'I OK';
else MSG = 'NOT OK';
end
