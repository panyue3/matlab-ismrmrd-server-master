function [ ImageFiltered, Variance, Threshold, p_value, Cutoff] = Wavelet_Filter( ImageSeries, varargin  )
%[ ImageFiltered, Threshold, p_value, Cutoff ] = Wavelet_Filter( ImageSeries, varargin, multip )
%   ImageSeries: input image series
%   option: option.WaveletName & option.beta
%   option.WaveletName: vwavlet name, default: 'db5'
%   option.beta: = 1, Gaussian Prior (Default); = 2, Laplacian Prior.
%   multip: threshold multiplication factor (used to match SNR of KW filter)
%
%   ImageFiltered: Wavelet Filtered images.
%   Threshold(i, j): Wavelet Shrinkage Threshold, 
%   i: eigenimage index, 
%   j: 1:3 horizontal, 4:6 verticle, 7:9 diagonal, for 2-D Wavelet
%   p_value: p_value of MP-law fitting, MUST be very close to 1.0
%   Cutoff: Eigenimage cutoff using MP-law
a_1     = ImageSeries;
p_value = 0.0;
Cutoff  = 0;
s       = size(a_1);

wname = 'db5';  % Default
beta = 1;       % Default
multip = 1;
if nargin == 2  % If there are two input variables
    option = varargin{1};
    if isfield(option, 'WaveletName')
        wname = option.WaveletName;
    end
    if isfield(option, 'beta')
        beta = option.beta;
    end
    if isfield(option, 'multip')
        multip = option.multip;
    end
    if isfield(option, 'noise_var')
        Variance = option.noise_var;
    else
        [a_I, V, D] = KL_Eigenimage(a_1);
        E = diag(D); %figure(4), hist(E, 24)
        [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
    end
else
    [a_I, V, D] = KL_Eigenimage(a_1);
    E = diag(D); %figure(4), hist(E, 24)
    [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
    %figure, semilogy(E, '*')
end
%wname = wname;

a_1_wavelet_filtered=zeros(s(1),s(2),s(3));

for m=1:s(3)
    m = m;
    wname = wname;
    size(a_1(:,:,m));
    [swa,swh,swv,swd]=swt2(a_1(:,:,m),3,wname);
    sorh='s';
    % For subband - Horizontal Details
    Threshold(m, 0+(1:3)) = Wavelet2D_Shrinkage_Selection( swh, Variance, beta );
    % For subband - Vertical Details
    Threshold(m, 3+(1:3)) = Wavelet2D_Shrinkage_Selection( swv, Variance, beta );
    % For subband - Diagonal Details
    Threshold(m, 6+(1:3)) = Wavelet2D_Shrinkage_Selection( swd, Variance, beta );
    for j = 1:3
        swh1(:,:,j)=wthresh(swh(:,:,j),sorh,(Threshold(m, 0 + j)*multip));
        swv1(:,:,j)=wthresh(swv(:,:,j),sorh,(Threshold(m, 3 + j)*multip));
        swd1(:,:,j)=wthresh(swd(:,:,j),sorh,(Threshold(m, 6 + j)*multip));
    end
    a_1_wavelet_filtered(:,:,m) = iswt2(swa(:,:,end),swh1,swv1,swd1,wname);
    
    %threshold_1(m) = Threshold(m, 3);
    %threshold_2(m) = Threshold(m, 6);
    %threshold_3(m) = Threshold(m, 9); 
end
%figure, plot(1:s(3), threshold_1, 1:s(3), threshold_2, 1:s(3), threshold_3)

ImageFiltered = a_1_wavelet_filtered;

end

