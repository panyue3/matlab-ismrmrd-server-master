function [channels,samples,line,partition,phase,channelId,EvalInfoMask,KSpaceCentrePartitionNo,KSpaceCentreLineNo,ScanCounter,TimeStamp,FreePara]= read_MDH(fid)

%%The header information is from the file "mdh.h".
%%The total size of the MDH header is 128 bytes.
%%Himanshu 06/14/2007


FlagsAndDMALength = fread(fid,1,'uint32');      % bit  0..24: DMA length [bytes]
                                               % bit     25: pack bit
                                               % bit 26..31: pci_rx enable flags
                                               % 4

MeasUID = fread(fid,1,'int32');                 % measurement user ID
                                               % 4

ScanCounter =  fread(fid,1,'uint32');           % scan counter [1...]
                                               % 4

TimeStamp  = fread(fid,1,'uint32');             % time stamp [2.5 ms ticks since 00:00]
                                               % 4

PMUTimeStamp = fread(fid,1,'uint32');           % PMU time stamp [2.5 ms ticks since last trigger]
                                               % 4

EvalInfoMask = fread(fid,2,'uint32');           % evaluation info mask field
                                               % 4*2 = 8

samples = fread(fid,1,'uint16');                % samples acquired in scan
                                               % 2

channels = fread(fid,1,'uint16');               % of channels used in scan
                                               % 2

LoopCounter = fread(fid,14,'uint16');           % loop counters
                                               % 14*2 = 28
     line = LoopCounter(1);            % line index
     acquisition = LoopCounter(2);     % acquisition index
     slice = LoopCounter(3);           % slice index
     partition = LoopCounter(4);       % partition index
     echo = LoopCounter(5);            % echo index
     phase = LoopCounter(6);           % phase index
     repetition = LoopCounter(7);      % measurement repeat index
     set = LoopCounter(8);             % set index
     seg = LoopCounter(9);             % segment index  (for TSE)
     Ida = LoopCounter(10);            % IceDimension a index
     Idb = LoopCounter(11);            % IceDimension b index
     Idc = LoopCounter(12);            % IceDimension c index
     Idd = LoopCounter(13);            % IceDimension d index
     Ide = LoopCounter(14);            % IceDimension e index


CutOff = fread(fid,2,'uint16');                 % cut-off values
                                               % 2*2 = 4
     Pre = CutOff(1);                  % write ushPre zeros at line start
     Post = CutOff(2);                 % write ushPost zeros at line end

KSpaceCentreColumn = fread(fid,1,'uint16');     % centre of echo
                                               % 2

CoilSelect = fread(fid,1,'uint16');     % Bit 0..3: CoilSelect
                                       % 2

ReadOutOffcentre = fread(fid,1,'float');% ReadOut offcenter value
                                       % 4

TimeSinceLastRF = fread(fid,1,'uint32');% Sequence time stamp since last RF pulse
                                       % 4

KSpaceCentreLineNo = fread(fid,1,'uint16'); % number of K-space centre line
                                           % 2

KSpaceCentrePartitionNo = fread(fid,1,'uint16'); % number of K-space centre partition
                                                % 2

IceProgramPara =  fread(fid,4,'uint16');         % free parameter for IceProgram
                                                % 2*4 = 8

FreePara =  fread(fid,4,'uint16');               % free parameter
                                                % 2*4 = 8

SliceData = fread(fid,7,'float');                % Slice Data
                                                % 4*7 = 28
       Sag = SliceData(1);
       Cor = SliceData(2);
       Tra = SliceData(3);
       Quaternion = SliceData(4:1:7); % rotation matrix as quaternion

channelId = fread(fid,1,'uint16');              % channel Id must be the last parameter
                                               % 2

PTABPosNeg = fread(fid,1,'uint16');                   % negative, absolute PTAB position in [0.1 mm]
                                                     % automatically set by PCI_TX firmware
                                                     % 2