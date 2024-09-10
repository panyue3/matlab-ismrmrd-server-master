function [ ImageFiltered, Variance, Threshold, p_value, Cutoff, V_trans ] = KW_Filter_Adam_Neigh( ImageSeries, varargin )
%[ ImageFiltered, Threshold, p_value, Cutoff ] = KW_Filter_Adam( ImageSeries, varargin )
%   ImageSeries: input image series
%   option: option.WaveletName & option.beta
%   option.WaveletName: vwavlet name, default: 'db1'
%   option.beta: = 1, Gaussian Prior (Default); = 2, Laplacian Prior.
%
%   ImageFiltered: KW Filtered images.
%   Threshold(i, j): Wavelet Shrinkage Threshold,
% 
% 
%   i: eigenimage index,
%   j: 1:3 horizontal, 4:6 verticle, 7:9 diagonal, for 2-D Wavelet
%   p_value: p_value of MP-law fitting, MUST be very close to 1.0
%   Cutoff: Eigenimage cutoff using MP-law, # of eigenimages to get rid of
%
%   20240327 Modification: adding the 4th dimension to deal with 2x
%   interpolation


wname = 'db1';  % Default
beta = 1;       % Default
p_value = 0;    % Default
Cutoff = 0;     % Default
multip = 1;     % Default
Threshold = [];

a_1 = ImageSeries;
s = size(a_1);
s_4 = size(a_1, 4);
clean_a_1_eigen_multip1=zeros(s(1),s(2),s(3), s_4);
ImageFiltered = zeros(s(1),s(2),s(3), s_4);
for i=1:s_4
    [a_I(:,:,:,i), V(:,:,i), D(:,:,i)] = KL_Eigenimage(a_1(:,:,:,i));
    if i==1, E = diag(D(:,:,i));end
end
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
        Variance = 1.3*option.noise_var;
        Cutoff = sum(E < 1.0*Variance);
        option.Cutoff = Cutoff;
        % disp([Variance, Cutoff])
    else     
        [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
    end
    if isfield(option, 'Cutoff')
        Cutoff = option.Cutoff;
    else
        [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
    end
else
    [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
end

for n=1:s_4
for m = 1:s(3) % Ding 20231128 Filter all eigen modes
% for m=(Cutoff+1):s(3)
    %m = m, Cutoff = Cutoff,
    wname = wname;
    %size(a_I(:,:,m));
%     [swa,swh,swv,swd]=swt2(a_I(:,:,m),3,wname);
%     sorh='s';
%     % For subband - Horizontal Details
%     Threshold(m, 0+(1:3)) = Wavelet2D_Shrinkage_Selection( swh, Variance, beta );
%     % For subband - Vertical Details
%     Threshold(m, 3+(1:3)) = Wavelet2D_Shrinkage_Selection( swv, Variance, beta );
%     % For subband - Diagonal Details
%     Threshold(m, 6+(1:3)) = Wavelet2D_Shrinkage_Selection( swd, Variance, beta );
%     for j = 1:3
%         swh1(:,:,j)=wthresh(swh(:,:,j),sorh,Threshold(m, 0 + j)*multip);
%         swv1(:,:,j)=wthresh(swv(:,:,j),sorh,Threshold(m, 3 + j)*multip);
%         swd1(:,:,j)=wthresh(swd(:,:,j),sorh,Threshold(m, 6 + j)*multip );
%     end
%     clean_a_1_eigen_multip1(:,:,m) = iswt2(swa(:,:,end),swh1,swv1,swd1,wname);
    if isreal(a_I)
        [clean_temp, thld] = Wavelet_Eig_Filt(a_I(:,:,m, n), Variance, beta, multip);
        %Threshold(m, :) = thld;
    else
        [clean_temp1, thld1] = Wavelet_Eig_Filt(real(a_I(:,:,m, n)), Variance/2, beta, multip);
        [clean_temp2, thld2] = Wavelet_Eig_Filt(imag(a_I(:,:,m, n)), Variance/2, beta, multip);
        %Threshold(m, :) = complex(thld1, thld2);
        clean_temp = complex(clean_temp1, clean_temp2);
    end
    
    clean_a_1_eigen_multip1(:,:,m, n) = clean_temp;
    %threshold_1(m) = Threshold(m, 3);
    %threshold_2(m) = Threshold(m, 6);
    %threshold_3(m) = Threshold(m, 9);
end
%figure, plot((Cutoff+1):s(3), threshold_1((Cutoff+1):s(3)), (Cutoff+1):s(3), threshold_2((Cutoff+1):s(3)), (Cutoff+1):s(3), threshold_3((Cutoff+1):s(3)))
for n=1:s_4
    ImageFiltered(:,:,:,n) = invKLT_3D(clean_a_1_eigen_multip1(:,:,:,n),V(:,:,n));
    V_trans(:,:,n) = V(:,:,n)';
end
end
end

function [clean_temp, Threshold] = Wavelet_Eig_Filt(a_I, Variance, beta, multip)
Wavelet_Level = 3;
wnames = {'db1','db4'};  % Set the wavelet used
perserve_l2_norm = true;
% Initialize Wavelet Transform
nddwt = nd_dwt_2D(wnames, [size(a_I,1), size(a_I,2)],'pres_l2_norm',perserve_l2_norm);
N_subband = 3*Wavelet_Level + 1;
switch Wavelet_Level
    case 1
        % Level = 1;
        S_Scaling = [0.5, 0.5, 0.5, 0.5];
    case 2
        % Level = 2;
        S_Scaling = [0.4045    0.2335    0.1546    0.0892    0.5000    0.5000    0.5000];
    case 3
        % Level = 3;
        S_Scaling = [0.3556    0.1590    0.0997    0.0446    0.2335    0.1545    0.0892    0.5    0.5    0.5];
    case 4
        % Level = 4;
        S_Scaling = [0.3239    0.1225    0.0749    0.0283    0.1590    0.0997    0.0446    0.2335    0.1545    0.0892    0.5    0.5   0.5];
end

a_swt2 = nddwt.dec(a_I, Wavelet_Level);
a_swt2_f = zeros(size(a_swt2));
for i=1:N_subband
    %Threshold  = Wavelet2D_Shrinkage_Selection( a_swt2(:,:,i), Variance*S_Scaling(i)^2 );
    Threshold  = Wavelet2D_NeighShrink_Selection( a_swt2(:,:,i), Variance*S_Scaling(i)^2 );
    a_swt2_f(:,:,i) = wthresh(a_swt2(:,:,i), 's', Threshold);
end
Threshold = mean(Threshold(:));
clean_temp = nddwt.rec(a_swt2_f);

end

