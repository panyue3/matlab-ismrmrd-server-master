function [ threshold ] = Wavelet2D_Shrinkage_Selection( Sub_band, Noise_V, varargin )
%This is based on the Grace Chang's paper
%Yu Ding 2012-09-24
%   threshold = Wavelet_Shrinkage_Selection( Sub_band, Noise_V, beta )
%   Three parameters:    
%   threshold = Wavelet_Shrinkage_Selection( Sub_band, Noise_V, beta )
%   Two parameters:    
%   threshold = Wavelet_Shrinkage_Selection( Sub_band, Noise_V )
%   beta: = 1, Gaussian Prior; = sqrt(8) Laplacian Prior
%   Sub_band: swh, swv, or swd in [swa,swh,swv,swd]=swt2(a_0,n,wname);
%   Noise_V: Noise variance
%   threshold: n x 1 array, n is level of wavelet, 

beta = 1.0;
if nargin == 3
    beta = varargin{1};
end
threshold = 0;
s = size(Sub_band);
if length(s) == 2 % 2-D wavelet, one level 
    
    Signal=std(Sub_band(:))^2 - Noise_V;
    if Signal > 0
        threshold = beta*(Noise_V)/sqrt(Signal);
    else % signal could be less than noise
        threshold = max(Sub_band(:)); % shrinkage all signal
    end
    
elseif length(s) == 3 % 2-D wavelet, multiple level
    threshold = zeros( s(3), 1 );
    for i=1:s(3)
        temp = Sub_band(:,:,i) ;
        Signal=std(temp(:))^2 - Noise_V;
        if (Signal > 0)
            threshold(i) = beta*(Noise_V)/sqrt(Signal); 
            %{ 'i=', i, 'Signal', Signal, '>0', 'threshold', threshold(i)}
        else % signal could be less than noise
            threshold(i) = max([max(real(temp(:))), max(imag(temp(:)))]); % shrinkage all signal
            %{ 'i=', i, 'Signal', Signal, '<0', 'threshold', threshold(i)}
        end
        
    end
    
else
    disp('Error! The Sub_band MUST be 2-D or 3-D ')
    return
end

end

