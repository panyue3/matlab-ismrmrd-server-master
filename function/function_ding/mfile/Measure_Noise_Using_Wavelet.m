% Noise_Map = Measure_Noise_Using_Wavelet(a_0, varargin)


function Noise_Map = Measure_Noise_Using_Wavelet(a_0, varargin)
% Ding 2013-09-06 Measure noise in the temporal direction

s_0 = size(a_0);
Noise_Map = zeros( s_0(1), s_0(2) );
if length(s_0)~= 3
    disp('Error! The input data array MUST be 3-D!')
    return
end
    
wname = 'db1';  % Default
if nargin == 2  % If there are two input variables
    option = varargin{1};
    if isfield(option, 'WaveletName')
        wname = option.WaveletName;
    end
end
disp(['Measure Noise Wavelet Name = ' wname])

for i=1:s_0(1)
    for j = 1:s_0(2)
        [SWA,SWD] = swt( a_0(i, j, :), 1, wname);
        Noise_Map(i, j) =  median(abs(SWD))/0.6745; 
    end
end







