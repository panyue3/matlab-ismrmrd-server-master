%% Translated from Amir's readPhilipsRaw function in IDL (2009-08-13 rel)
% Xiangyu Yang
% Ohio State University Imaging Core Lab
% 2011-03-15

%% Input: (filename, InStruct, varargin)
% filename: a string contains the name of the Philips .list file.
% InStruct: a structure passes variable I/O matrices information to this
%   function. If the user wants to have the complex data exported in the
%   variable output structure, he/she should set the 'STD' field as an
%   empty matrix in InStruct. An existing matrix can be passed with the
%   REJ/PHX/FRX/NOI/NAV fields, too.
%     STD: Standard data vector
%     REJ = Rejected standard data vector
%       (only for scans with arrhythmia rejection)
%     PHX = Correction data vector for EPI/GraSE phase correction
%     FRX = Correction data vector for frequency spectrum correction
%     NOI = Preparation phase data vector for noise determination
%     NAV = Phase navigator data vector
% varargin: variable input arguments:
%   varargin = slice, coil, echo, aver, dyn, mix
%     slice: slice number (starts from 1)
%     coil:  coil element (starts from 1)
%     echo:  echo number (starts from 1)
%     aver:  sequence number of this signal average (starts from 1)
%     dyn:   dynamic scan number (starts from 1)
%     mix:   mixed sequence number (starts from 1)

%% Output: [phComm, varargout]
% phComm: a structure that contains basic sequence information
%   (for definition of phComm fields, see line 469-490.
% varargout: variable output parameters:
%   varargout only has one output structure that contains all the matrices
%   specified in InStruct. For example, if InStruct contains the STD field,
%   the corresponding field in OutStruct contains the complex data matrix.
%   This parameter can be ommited if the user only wants to exact sequence
%   information from the raw data file.

%% Example:
%  1. To extract basic sequence information:
%    filename = 'D:\temp\raw_002.list';
%    InStruct = struct();
%    phComm = readPhilipsRaw(filename, InStruct)
%
%  2. To read in the complex data of slice 1 / the first used coil element
%     / echo 1 when there is no average/dynamic/mixed sequence.
%    InStruct.STD = [];
%    slice = 1;
%    used_coils = phComm.used_coils;
%    coil = used_coils(1);
%    echo = 1;
%    [phComm, OutStruct] = readPhilipsRaw(filename, InStruct, slice, coil,
%        echo)
 


function [phComm, varargout] = readPhilipsRaw(filename, InStruct, varargin)

    nout = max(nargout, 1) - 1;
  
    min_narg = 2;
    
    % Input check:
    DefaultFields = {'STD', 'REJ', 'PHX', 'FRX', 'NOI', 'NAV'};
    InputFields = upper(fieldnames(InStruct));
    % Find specified parameters:
    SpecifiedPar = intersect(DefaultFields, InputFields);
    
    if ~isempty(intersect(SpecifiedPar, 'STD'))
        cData = InStruct.STD;
        dSTD = 1;
    else
        dSTD = 0;
    end
    
    if ~isempty(intersect(SpecifiedPar, 'REJ'))
        rej = InStruct.REJ;
        dREJ = 1;
    else
        dREJ = 0;
    end
    
    if ~isempty(intersect(SpecifiedPar, 'PHX'))
        phx = InStruct.PHX;
        dPHX = 1;
    else
        dPHX = 0;
    end
    
    if ~isempty(intersect(SpecifiedPar, 'FRX'))
        frx = InStruct.FRX;
        dFRX = 1;
    else
        dFRX = 0;
    end
    
    if ~isempty(intersect(SpecifiedPar, 'NOI'))
        noi = InStruct.NOI;
        dNOI = 1;
    else
        dNOI = 0;
    end
    
    if ~isempty(intersect(SpecifiedPar, 'NAV'))
        nav = InStruct.NAV;
        dNAV = 1;
    else
        dNAV = 0;
    end

    % IDL indices start with 0:
    if nargin < min_narg + 1
        slice = 0;
    else
        slice = varargin{1} - 1;
    end
    
    if nargin < min_narg + 2
        coil = 0;
    else
        coil = varargin{2} - 1;
    end
    
    if nargin < min_narg + 3
        echo = 0;
    else
        echo = varargin{3} - 1;
    end
    
    % For some reason, Amir did not set default values for aver, dyn, and
    % mix. 
    if nargin < min_narg + 4
        aver = 0;
    else
        aver = varargin{4} - 1;
    end
    
    if nargin < min_narg + 5
        dyn = 0;
    else
        dyn = varargin{5} - 1;
    end
    
    if nargin < min_narg + 5
        mix = 0;
    else
        dyn = varargin{6} - 1;
    end
    
    % The real stuff starts here:
    i1 = length(filename);
    if i1 > 5
        s1 = upper(filename(i1-4:i1));
        if strcmp(s1, '.LIST') || strcmp(s1, '.DATA')
            filename = filename(1:i1-5);
        end
    end
    
    % Parameter initialization is not always necessary in Matlab -- some of
    % these codes may be redundant.
    s1 = '';      s2 = '';
    i1 = 0;       i2 = 0;       i3 = 0;
    v1 = 0.;      v2 = 0.;
    dim1 = 0;     dim2 = 0;     dim3 = 0;
    index = zeros(1, 19);
    intxt = '';
    Zresolution = 0;
    kx_range = [0, 0];
    ky_range = [0, 0];
    kz_range = [0, 0];
    number_of_coil_channels = 1;
    NOIsize = 0;
    kyStep = 0;
    kx_oversample_factor = 1.0;
    ky_oversample_factor = 1.0;
    kz_oversample_factor = 1.0;
    number_of_encoding_dimensions = 0;
    number_of_locations = 1;
    used_coils = repmat(-1, 1, 128);
    no_echoes = repmat(-1, 1, 128);
    number_of_extra_attribute_1_values = 1;
    number_of_extra_attribute_2_values = 1;
    number_of_signal_averages = 1;
    number_of_dynamic_scans = 1;
    number_of_cardiac_phases = 1;
    isize = 17;
    ioffset = 18;
    ooffset = 0;
    two32 = 2^32;
    
    lis = fopen(strcat(filename, '.list'), 'r');
    
    while ~feof(lis)
        intxt = fgets(lis);
        first = intxt(1);
        
        switch first
            case '#'
                i1 = strfind(intxt, 'Gyroscan SW release');
                if ~isempty(i1)
                    s_pos = findstr(intxt, ' :');
                    if ~isempty(s_pos)
                        tmp = numel(s_pos);
                        s = strtrim(intxt(s_pos(tmp)+2:numel(intxt)));
                    else
                        s = intxt;
                    end
                    switch s
                        case '1.2-1'
                            isize = 17; ioffset = 18;
                        case '1.2-2'
                            isize = 17; ioffset = 18;
                        case '2.1-3'
                            isize = 18; ioffset = 19;
                        case '2.5-3'
                            isize = 18; ioffset = 19;
                        case '2.6-1'
                            isize = 18; ioffset = 19;
                        otherwise
                            isize = 18; ioffset = 19;
                    end
                    index = zeros(1, ioffset+1);
                end
                
                i1 = strfind(intxt, 'START OF DATA VECTOR INDEX');
                if ~isempty(i1)
                    if dim1 == 0
                        dim1 = abs(kx_range(2) - kx_range(1)) + 1;
                        if dim1 == 1
                            dim1 = Xresolution;
                        end
                    end
                    if dim2 == 0
                        dim2 = abs(ky_range(2) - ky_range(1)) + 1;
                        if dim2 == 1
                            dim2 = Yresolution;
                        end
                    end
                    if (dim3 == 0) & (Zresolution > 0)
                        dim3 = abs(kz_range(2) - kz_range(1)) + 1;
                        if dim3 == 1
                            dim3 = Zresolution;
                        end
                    end
                    if dSTD
                        if dim3 > 0
                            dummyc = complex(0., 0.);
                            cData = repmat(dummyc, [dim1, dim2, dim3]);
                        else
                            dummyc = complex(0., 0.);
                            cData = repmat(dummyc, [dim1, dim2]);
                        end
                    end
                    dat = fopen(strcat(filename, '.data'), 'r');
                    % The byte size information can be obtained from the
                    % 'bytes' attribute of the structure returned from the
                    % dir command:
                    dir_info = dir(strcat(filename, '.data'));
                end
                
            case '.'
                intxt1 = intxt(2:18);
                i_array = str2num(intxt1);
                i1 = i_array(1);  i2 = i_array(2);  i3 = i_array(3);
                s2 = strtrim(intxt(19:52));
                intxt1 = intxt(55:length(intxt));
                switch s2
                    case 'number_of_mixes'
                        number_of_mixes = str2num(intxt1);
                    case 'number_of_encoding_dimensions'
                        number_of_encoding_dimensions = str2num(intxt1);
                    case 'number_of_dynamic_scans'
                        number_of_dynamic_scans = str2num(intxt1);
                    case 'number_of_cardiac_phases'
                        number_of_cardiac_phases = str2num(intxt1);
                    case 'number_of_echoes'
                        number_of_echoes = str2num(intxt1);
                    case 'number_of_locations'
                        number_of_locations = str2num(intxt1);
                        dim = zeros(number_of_locations, 4);
                    case 'number_of_extra_attribute_1_values'
                        number_of_extra_attribute_1_values = str2num(intxt1);
                    case 'number_of_extra_attribute_2_values'
                        number_of_extra_attribute_2_values = str2num(intxt1);
                    case 'number_of_signal_averages'
                        number_of_signal_averages = str2num(intxt1);
                    case 'number_of_coil_channels'
                        number_of_coil_channels = str2num(intxt1);
                    case 'kx_range'
                        if i2 == echo
                            kx_range = str2num(intxt1);
                            dim1 = kx_range(2) - kx_range(1) + 1;
                        end
                    case 'ky_range'
                        if i2 == echo
                            ky_range = str2num(intxt1);
                            dim2 = ky_range(2) - ky_range(1) + 1;
                        end
                    case 'kz_range'
                        if i2 == echo
                            kz_range = str2num(intxt1);
                            dim3 = kz_range(2) - kz_range(1) + 1;
                        end
                    case 'kx_oversample_factor'
                        kx_oversample_factor = str2num(intxt1);
                    case 'ky_oversample_factor'
                        ky_oversample_factor = str2num(intxt1);
                    case 'kz_oversample_factor'
                        kz_oversample_factor = str2num(intxt1);
                    case 'X-resolution'
                        Xresolution = str2num(intxt1);
                    case 'Y-resolution'
                        Yresolution = str2num(intxt1);
                    case 'Z-resolution'
                        Zresolution = str2num(intxt1);
                    case 'X_range'
                        X_range = str2num(intxt1);
                        dim(i3+1, 1:2) = X_range;
                    case 'Y_range'
                        Y_range = str2num(intxt1);
                        dim(i3+1, 3:4) = Y_range;
                end
                
            case ' '
                [s1, index_str] = strtok(intxt, ' ');
                s1 = strtrim(s1);
                index_num = str2num(index_str);
                n = numel(index_num) + 1;
                % Not sure if break works here ...
                if n < ioffset
                    break
                end
                index = index_num;
                if index(ioffset) < 0
                    index(ioffset) = ooffset;
                end
                ooffset = index(ioffset) + index(isize+1);
                switch s1
                    case 'NOI'
                        if dNOI
                            if (index(6) == coil) && (index(5) == slice)
                                if ~isempty(noi)
                                    noi = expandArray(noi, dat, index, isize, ioffset);
                                else
                                    fseek(dat, index(ioffset+1), 'bof');
                                    noi = fread(dat, [2, index(isize+1)/8], 'float');
                                    noi = complex(noi(1, :), noi(2, :));
                                    noi = noi.';
                                end
                            end
                        end
                    case 'REJ'
                        if dREJ
                            if (index(6) == coil) && (index(4) == echo) ...
                               && (index(5) == slice)
                                if ~isempty(rej)
                                    rej = expandArray(rej, dat, index, isize, ioffset);
                                else
                                    fseek(dat, index(ioffset+1), 'bof');
                                    rej = fread(dat, [2, index(isize+1)/8], 'float');
                                    rej = complex(rej(1, :), rej(2, :));
                                    rej = rej.';
                                end
                            end
                        end
                    case 'PHX'
                        if dPHX
                            if (index(6) == coil) && (index(4) == echo) ...
                               && (index(5) == slice)
                                if ~isempty(phx)
                                    phx = expandArray(phx, dat, index, isize, ioffset);
                                else
                                    fseek(dat, index(ioffset+1), 'bof');
                                    phx = fread(dat, [2, index(isize+1)/8], 'float');
                                    phx = complex(phx(1, :), phx(2, :));
                                    phx = phx.';
                                end
                            end
                        end
                    case 'FRX'
                        if dFRX
                            if (index(6) == coil) && (index(4) == echo) ...
                               && (index(5) == slice) && (index(12) == aver) ...
                               && (index(1) == mix) && (index(2) == dyn)
                                if ~ isempty(frx)
                                    frx = expandArray(frx, dat, index, isize, ioffset);
                                else
                                    fseek(dat, index(ioffset+1), 'bof');
                                    frx = fread(dat, [2, index(isize+1)/8], 'float');
                                    frx = complex(frx(1, :), frx(2, :));
                                    frx = frx.';
                                end
                            end
                        end
                    case 'NAV'
                        if dNAV
                            if (index(6) == coil) && (index(4) == echo) ...
                               && (index(5) == slice)
                                if ~isempty(nav)
                                    nav = expandArray(nav, dat, index, isize, ioffset);
                                else
                                    fseek(dat, index(ioffset+1), 'bof');
                                    nav = fread(dat, [2, index(isize+1)/8], 'float');
                                    nav = complex(nav(1, :), nav(2, :));
                                    nav = nav.';
                                end
                            end
                        end
                    case 'STD'
                        tmp = index(4); no_echoes(tmp+1) = tmp;
                        tmp = index(6); used_coils(tmp+1) = tmp;
                        if dSTD
                            if (index(6) == coil) && (index(4) == echo) ...
                               && (index(12) == aver) && (index(3) == dyn)
                                if dim3 == 0
                                    if index(5) == slice
                                        if index(isize+1) == 0
                                            toff = dim1 * 8 * kyStep + 30000;
                                        else
                                            toff = index(ioffset+1);
                                        end
                                        if toff+dim1*8 <= dir_info.bytes
                                            fseek(dat, toff, 'bof');
                                            raw = fread(dat, [2, dim1], 'float');
                                            raw = complex(raw(1, :), raw(2, :));
                                            raw = raw.';
                                            cData(:, index(9)-ky_range(1)+1) = raw(:);
                                        end
                                    end
                                else
                                    if index(ioffset+1) < 0
                                        index(ioffset+1) = tw032 + index(ioffset+1);
                                    end
                                    if index(ioffset+1) + index(ioffset) < dir_info.bytes
                                        fseek(dat, index(ioffset+1), 'bof');
                                        raw = fread(dat, [2, dim1], 'float');
                                        raw = complex(raw(1, :), raw(2, :));
                                        raw = raw.';
                                    end
                                    cData(:, index(9)-ky_range(1)+1, index(10)-kz_range(1)+1) = raw(:);
                                end
                            end
                            kyStep = kyStep + 1;
                        end
                    otherwise
                        intxt
                end
            otherwise
                intxt
        end
    end
    
    fclose(lis);
    fclose(dat);

    no_echoes = max(no_echoes) + 1;
    % The used_coils information in this translation is different from the
    % orignial IDL version in two aspects: 1. the Matlab index starts from
    % 1 while the IDL index starts from 0, so used_coils(Matlab) =
    % used_coils(IDL) + 1; 2. I did not put this variable in a pointer.
    used_coils = find(used_coils > -1);
    k_range = [kx_range, ky_range, kz_range];
    
    % The origninal IDL codes clear phComm here because unexpected values
    % may be passed to this function through this keyword. In this Matlab
    % translation, phComm is defined as an output variable so there is no
    % need for cleaning.
    
    phComm = struct('dim1', dim1, 'dim2', dim2, 'dim3', dim3, ...
                    'k_range', k_range, ...
                    'Xresolution', Xresolution, ...
                    'Yresolution', Yresolution, ...
                    'Zresolution', Zresolution, ...
                    'kx_oversample_factor', kx_oversample_factor, ...
                    'ky_oversample_factor', ky_oversample_factor, ...
                    'kz_oversample_factor', kz_oversample_factor, ...
                    'no_echoes', no_echoes, ...
                    'used_coils', used_coils, ...
                    'number_of_locations', number_of_locations, ...
                    'number_of_coil_channels', number_of_coil_channels, ...
                    'number_of_encoding_dimensions', ...
                        number_of_encoding_dimensions, ...
                    'number_of_extra_attribute_1_values', ...
                        number_of_extra_attribute_1_values, ...
                    'number_of_extra_attribute_2_values', ...
                        number_of_extra_attribute_2_values, ...
                    'number_of_signal_averages', number_of_signal_averages, ...
                    'number_of_dynamic_scans', number_of_dynamic_scans, ...
                    'number_of_cardiac_phases', number_of_cardiac_phases...
                   );
               
    % Variable output structure:
    if nout > 0
        if dSTD
            OutStruct.STD = cData;
        end
        if dREJ
            OutStruct.REJ = rej;
        end
        if dPHX
            OutStruct.PHX = phx;
        end
        if dFRX
            OutStruct.FRX = frx;
        end
        if dNOI
            OutStruct.NOI = noi;
        end
        if dNAV
            OutStruct.NAV = nav;
        end    
        varargout{1} = OutStruct;
    end
               
end