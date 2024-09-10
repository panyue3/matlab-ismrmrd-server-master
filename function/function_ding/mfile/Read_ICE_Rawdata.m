
function [kspace, Noise, ref, prot] = Read_ICE_Rawdata(fname) 
% read the Ice meas data
% /*--------------------------------------------------------------------------*/
% /*  Definition of measurement data header                                   */
% /*--------------------------------------------------------------------------*/
% typedef struct
% {
%   PACKED_MEMBER( uint32_t,     ulFlagsAndDMALength           );    // bit  0..24: DMA length [bytes]
%                                                                    // bit     25: pack bit
%                                                                    // bit 26..31: pci_rx enable flags                   4 byte
%   PACKED_MEMBER( int32_t,      lMeasUID                      );    // measurement user ID                               4
%   PACKED_MEMBER( uint32_t,     ulScanCounter                 );    // scan counter [1...]                               4
%   PACKED_MEMBER( uint32_t,     ulTimeStamp                   );    // time stamp [2.5 ms ticks since 00:00]             4
%   PACKED_MEMBER( uint32_t,     ulPMUTimeStamp                );    // PMU time stamp [2.5 ms ticks since last trigger]  4
%   PACKED_MEMBER( uint32_t,     aulEvalInfoMask[MDH_NUMBEROFEVALINFOMASK] ); // evaluation info mask field           8
%   PACKED_MEMBER( uint16_t,     ushSamplesInScan              );    // # of samples acquired in scan                     2
%   PACKED_MEMBER( uint16_t,     ushUsedChannels               );    // # of channels used in scan                        2   =32
%   sLoopCounter sLC;																					 			 // loop counters                                    28   =60
%   sCutOffData sCutOff;    																				 // cut-off values                                    4
%   PACKED_MEMBER( uint16_t,     ushKSpaceCentreColumn         );    // centre of echo                                    2
%   PACKED_MEMBER( uint16_t,     ushCoilSelect                 );    // Bit 0..3: CoilSelect                              2
%   PACKED_MEMBER( float,        fReadOutOffcentre             );    // ReadOut offcenter value                           4
%   PACKED_MEMBER( uint32_t,     ulTimeSinceLastRF             );    // Sequence time stamp since last RF pulse           4
%   PACKED_MEMBER( uint16_t,     ushKSpaceCentreLineNo         );    // number of K-space centre line                     2
%   PACKED_MEMBER( uint16_t,     ushKSpaceCentrePartitionNo    );    // number of K-space centre partition                2
%   PACKED_MEMBER( uint16_t,     aushIceProgramPara[MDH_NUMBEROFICEPROGRAMPARA] ); // free parameter for IceProgram   8   =88
%   PACKED_MEMBER( uint16_t,     aushFreePara[MDH_FREEHDRPARA] );    // free parameter                          4 * 2 =   8
%   sSliceData sSD;																									 // Slice Data                                       28   =124
%   PACKED_MEMBER( uint16_t,	   ushChannelId                  );    // channel Id must be the last parameter             2
%   PACKED_MEMBER( uint16_t,	   ushPTABPosNeg                 );    // negative, absolute PTAB position in [0.1 mm]      2
%                                                                    // (automatically set by PCI_TX firmware)
% } sMDH;                                                            // total length: 32 * 32 Bit (128 Byte)            128
%
% sLC: ICE loopcounter: [Line Acq Slice Partition Echo Phase Rep Set Seg Ida Idb Idc Idd Ide]
%
% EvalInfoMask
% /*--------------------------------------------------------------------------*/
% /*  Definition of EvalInfoMask:                                             */
% /*--------------------------------------------------------------------------*/
% const MdhBitField MDH_ACQEND            ((unsigned long)0);
% const MdhBitField MDH_RTFEEDBACK        (1);
% const MdhBitField MDH_HPFEEDBACK        (2);
% const MdhBitField MDH_ONLINE            (3);
% const MdhBitField MDH_OFFLINE           (4);
% const MdhBitField MDH_SYNCDATA          (5);       // readout contains synchroneous data
% const MdhBitField MDH_LASTSCANINCONCAT  (8);       // Flag for last scan in concatination
% 
% const MdhBitField MDH_RAWDATACORRECTION (10);      // Correct the rawadata with the rawdata correction factor
% const MdhBitField MDH_LASTSCANINMEAS    (11);      // Flag for last scan in measurement
% const MdhBitField MDH_SCANSCALEFACTOR   (12);      // Flag for scan specific additional scale factor
% const MdhBitField MDH_2NDHADAMARPULSE   (13);      // 2nd RF exitation of HADAMAR
% const MdhBitField MDH_REFPHASESTABSCAN  (14);      // reference phase stabilization scan         
% const MdhBitField MDH_PHASESTABSCAN     (15);      // phase stabilization scan
% const MdhBitField MDH_D3FFT             (16);      // execute 3D FFT         
% const MdhBitField MDH_SIGNREV           (17);      // sign reversal
% const MdhBitField MDH_PHASEFFT          (18);      // execute phase fft     
% const MdhBitField MDH_SWAPPED           (19);      // swapped phase/readout direction
% const MdhBitField MDH_POSTSHAREDLINE    (20);      // shared line               
% const MdhBitField MDH_PHASCOR           (21);      // phase correction data    
% const MdhBitField MDH_PATREFSCAN        (22);      // additonal scan for PAT reference line/partition
% const MdhBitField MDH_PATREFANDIMASCAN  (23);      // additonal scan for PAT reference line/partition that is also used as image scan
% const MdhBitField MDH_REFLECT           (24);      // reflect line              
% const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4        
% const MdhBitField MDH_SHARENOW          (26);      // all lines are acquired from the actual and previous e.g. phases
% const MdhBitField MDH_LASTMEASUREDLINE  (27);      // indicates that the current line is the last measured line of all succeeding e.g. phases
% const MdhBitField MDH_FIRSTSCANINSLICE  (28);      // indicates first scan in slice (needed for time stamps)
% const MdhBitField MDH_LASTSCANINSLICE   (29);      // indicates  last scan in slice (needed for time stamps)
% const MdhBitField MDH_TREFFECTIVEBEGIN  (30);      // indicates the begin time stamp for TReff (triggered measurement)
% const MdhBitField MDH_TREFFECTIVEEND    (31);      // indicates the   end time stamp for TReff (triggered measurement)
% const MdhBitField MDH_MDS_REF_POSITION  (32);      // indicates the reference position for move during scan images (must be set once per slice/partition in MDS mode)
% const MdhBitField MDH_SLC_AVERAGED      (33);      // indicates avveraged slice for slice partial averaging scheme
% 
% const MdhBitField MDH_FIRST_SCAN_IN_BLADE       (40);  // Marks the first line of a blade
% const MdhBitField MDH_LAST_SCAN_IN_BLADE        (41);  // Marks the last line of a blade
% const MdhBitField MDH_LAST_BLADE_IN_TR          (42);  // Set for all lines of the last BLADE in each TR interval
% 
% const MdhBitField MDH_RETRO_LASTPHASE           (45);  // Marks the last phase in a heartbeat
% const MdhBitField MDH_RETRO_ENDOFMEAS           (46);  // Marks an ADC at the end of the measurement
% const MdhBitField MDH_RETRO_REPEATTHISHEARTBEAT (47);  // Repeat the current heartbeat when this bit is found
% const MdhBitField MDH_RETRO_REPEATPREVHEARTBEAT (48);  // Repeat the previous heartbeat when this bit is found
% const MdhBitField MDH_RETRO_ABORTSCANNOW        (49);  // Just abort everything
% const MdhBitField MDH_RETRO_LASTHEARTBEAT       (50);  // This adc is from the last heartbeat (a dummy)
% const MdhBitField MDH_RETRO_DUMMYSCAN           (51);  // This adc is just a dummy scan, throw it away
% const MdhBitField MDH_RETRO_ARRDETDISABLED      (52);  // Disable all arrhythmia detection when this bit is found
% 
% //-----------------------------------------------------------------------------
% // Definition of EvalInfoMask for COP:
% //-----------------------------------------------------------------------------
% #define	MDH_COP_ACQEND            (0x00000001)
% #define MDH_COP_RTFEEDBACK        (0x00000002)
% #define MDH_COP_HPFEEDBACK        (0x00000004)
% #define	MDH_COP_ONLINE            (0x00000008)
% #define	MDH_COP_OFFLINE           (0x00000010)

[Data, asc, prot] =Read_RawData(fname);
prot = char(prot);
S0 = size(Data);
numOfLines = S0(2);

% find the noise lines and seperate ref lines if any
numOfNoiseLines = 0; NoiseLines = [];
numOfSeperateRefLines = 0; RefLines = [];
for i=1:length(asc)   
    if ( IsNoiseScan(asc(i).aulEvalInfoMask(1))  )
        numOfNoiseLines = numOfNoiseLines + 1;
        NoiseLines = [NoiseLines; i];
    end
    
    if ( IsSeperateRef(asc(i).aulEvalInfoMask(1)) )
        numOfSeperateRefLines = numOfSeperateRefLines + 1;
        RefLines = [RefLines; i];
    end
end

% [Col Line Cha Acq Slice Partition Echo Phase Rep Set Seg
% 11 dimension array
sLC = zeros(numOfLines-numel(NoiseLines)-numel(RefLines), 11);
sLCRef = zeros(numOfSeperateRefLines, 11);
sLCNoise = zeros(numOfNoiseLines, 11);
l = 0;
r = 0;
n = 0;
for i=1:length(asc)
    
    if ( IsAcqEnd(asc(i).aulEvalInfoMask(1)) )
        continue;
    end

    if ( ~isempty(find(i==NoiseLines)) )
        n = n + 1;
        sLCNoise(n,:) = fillSLC(asc(i));
    end
    
    if ( ~isempty(find(i==RefLines))  )
        r = r + 1;
        sLCRef(r,:) = fillSLC(asc(i));
    end
    
    l = l + 1;
    sLC(l,:) = fillSLC(asc(i));
end
sLC = sLC(1:l, :);
kspace = allocateKSpace(sLC);

% noise data if any
if ( numOfNoiseLines > 0 )
    maxColNoise = max(sLCNoise(:, 1));
    Noise = zeros(maxColNoise, numOfNoiseLines);
else
    Noise = [];
end

% seperate reference lines
if ( numOfSeperateRefLines > 0 )
    ref = allocateKSpace(sLCRef);
else
    ref = [];
end

% put the data into the array

l = 0;
r = 0;
n = 0;
for i=1:length(asc)
    
    if ( IsAcqEnd(asc(i).aulEvalInfoMask(1)) )
        continue;
    end

    if ( ~isempty(find(i==NoiseLines)) )
        n = n + 1;
        N = length(Data(:, i));
        aZ = addPrePostZeros(asc(i));
        if ( aZ == 0 )
            Noise(1:N, n) = Data(:, i);
        elseif ( aZ == 1 ) % pre zeros
            Noise(end-N+1:end, n) = Data(:, i);
        elseif ( aZ == 2 ) % post zeros
            Noise(1:N, n) = Data(:, i);
        end
        continue;
    end
    
    if ( ~isempty(find(i==RefLines))  )
        r = r + 1;
        N = length(Data(:, i));
        aZ = addPrePostZeros(asc(i));
        if ( aZ == 0 )
            ref(1:N, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
                sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
        elseif ( aZ == 1 ) % pre zeros
            ref(end-N+1:end, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
                sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
        elseif ( aZ == 2 ) % post zeros
            ref(1:N, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
                sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
        end        
        continue;
    end
    
    l = l + 1;
    N = length(Data(:, i));
    aZ = addPrePostZeros(asc(i));
    if ( aZ == 0 )
        kspace(1:N, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
            sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
    elseif ( aZ == 1 ) % pre zeros
        kspace(end-N+1:end, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
            sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
    elseif ( aZ == 2 ) % post zeros
        kspace(1:N, sLCRef(r,2), sLCRef(r,3), sLCRef(r,4), sLCRef(r,5), ...
            sLCRef(r,6), sLCRef(r,7), sLCRef(r,8), sLCRef(r,9), sLCRef(r,10), sLCRef(r,11)) = Data(:, i);
    end    
end
clear Data

    % --------------------------------------------
    % parse the Eval Info Mask
    function bValue = IsNoiseScan(evalInfoMask)
        % const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4
        p = dec2bin(evalInfoMask(1));
        len = numel(p);
        if ( len >= 26 )
            if ( p(end-25) == '1' )
                bValue = 1;
            else
                bValue = 0;
            end
        else
            bValue = 0;
        end
    end

    % --------------------------------------------
    % the seperate reference lines
    function bValue = IsSeperateRef(evalInfoMask)
        % const MdhBitField MDH_PATREFSCAN        (22);      // additonal scan for PAT reference line/partition
        p = dec2bin(evalInfoMask(1));
        len = numel(p);
        if ( len >= 23 )
            if ( p(end-22) == '1' )
                bValue = 1;
            else
                bValue = 0;
            end
        else
            bValue = 0;
        end
    end
    % --------------------------------------------
    % the acq end line
    function bValue = IsAcqEnd(evalInfoMask)
        % const MdhBitField MDH_ACQEND            ((unsigned long)0);
        bValue = (evalInfoMask(1)==0);
    end
    % --------------------------------------------
    % allocate kspace
    function kspaceAllocated = allocateKSpace(sLC)
        maxCol = max(sLC(:,1)); % starting from 1
        maxLine = max(sLC(:,2)) + 1;
        maxCha = max(sLC(:,3)) + 1;
        maxAcq = max(sLC(:,4)) + 1;
        maxSlice = max(sLC(:,5)) + 1;
        maxPar = max(sLC(:,6)) + 1;
        maxEcho = max(sLC(:,7)) + 1;
        maxPhs = max(sLC(:,8)) + 1;
        maxRep = max(sLC(:,9)) + 1;
        maxSet = max(sLC(:,10)) + 1;
        maxSeg = max(sLC(:,11)) + 1;

        % allocate the data 
        kspaceAllocated = zeros(maxCol, maxLine, maxCha, maxAcq, maxSlice, maxPar, maxEcho, maxPhs, maxRep, maxSet, maxSeg, 'single');
    end
    % --------------------------------------------
    % fill the sLC
    function aSLC = fillSLC(aAsc)
        
        if ( 2*aAsc.ushKSpaceCentreColumn >= aAsc.ushSamplesInScan )
            aSLC(1) = 2*aAsc.ushKSpaceCentreColumn;
        else
            aSLC(1) = 2*(aAsc.ushSamplesInScan - aAsc.ushKSpaceCentreColumn);
        end
        
        aSLC(1) = max([2*aAsc.ushKSpaceCentreColumn aAsc.ushSamplesInScan]);
        aSLC(2) = aAsc.sLC(1); % Line
        aSLC(3) = aAsc.ushChannelId; % channel
        aSLC(4:11) = aAsc.sLC(2:9); % other dimensions
    end
    % --------------------------------------------
    % add pre or post zeros
    function aZ = addPrePostZeros(aAsc)
        % aZ = 1 : pre zeros
        % aZ = 2 : post zeros
        % aZ = 0 : no zeros
        if ( 2*aAsc.ushKSpaceCentreColumn == aAsc.ushSamplesInScan )
            aZ = 0;
            return;
        end
        
        if ( 2*aAsc.ushKSpaceCentreColumn < aAsc.ushSamplesInScan )
            aZ = 1;
            return;
        end
        
        if ( 2*aAsc.ushKSpaceCentreColumn > aAsc.ushSamplesInScan )
            aZ = 2;
            return;
        end
        
    end
end