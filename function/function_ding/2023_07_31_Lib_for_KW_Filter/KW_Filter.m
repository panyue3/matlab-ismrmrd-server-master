function [ ImageFiltered, Variance, Threshold, p_value, Cutoff ] = KW_Filter( ImageSeries, varargin )
%[ ImageFiltered, Threshold, p_value, Cutoff ] = KW_Filter( ImageSeries, varargin )
%   ImageSeries: input image series
%   option: option.WaveletName & option.beta
%   option.WaveletName: vwavlet name, default: 'db5'
%   option.beta: = 1, Gaussian Prior (Default); = 2, Laplacian Prior.
%
%   ImageFiltered: KW Filtered images.
%   Threshold(i, j): Wavelet Shrinkage Threshold,
%   i: eigenimage index,
%   j: 1:3 horizontal, 4:6 verticle, 7:9 diagonal, for 2-D Wavelet
%   p_value: p_value of MP-law fitting, MUST be very close to 1.0
%   Cutoff: Eigenimage cutoff using MP-law, # of eigenimages to get rid of

wname = 'db1';  % Default
beta = 1;       % Default
p_value = 0;    % Default
Cutoff = 0;     % Default
multip = 1;     % Default
Threshold = 0;

a_1 = ImageSeries;
s = size(a_1);
clean_a_1_eigen_multip1=zeros(s(1),s(2),s(3));
[a_I, V, D] = KL_Eigenimage(a_1);

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
    if isfield(option, 'Cutoff')
        Cutoff = option.Cutoff;
    else
        
        E = diag(D); %figure(4), hist(E, 24)
        [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
    end
else
    
    E = diag(D); %figure(4), hist(E, 24), %figure, semilogy(E, '*')
    [Cutoff, Variance, ks, beta_MP, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));
end
%disp({'KW Filter Cutoff = ', Cutoff})
a_I( :, :, 1:Cutoff ) = 0;
%size(a_I)
for m=(Cutoff+1):s(3)
    %m = m, Cutoff = Cutoff,
    wname = wname;
    size(a_I(:,:,m));
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
        [clean_temp, Threshold] = Wavelet_Eig_Filt(a_I, m, wname, Variance, beta, multip);
    else
        [clean_temp1, Threshold1] = Wavelet_Eig_Filt(real(a_I), m, wname, Variance, beta, multip);
        [clean_temp2, Threshold2] = Wavelet_Eig_Filt(imag(a_I), m, wname, Variance, beta, multip);
        clean_temp = complex( clean_temp1, clean_temp2 );
        Threshold = complex(Threshold1, Threshold2);
    end
    clean_a_1_eigen_multip1(:,:,m) = clean_temp;
    %threshold_1(m) = Threshold(m, 3);
    %threshold_2(m) = Threshold(m, 6);
    %threshold_3(m) = Threshold(m, 9);
end
%figure, plot((Cutoff+1):s(3), threshold_1((Cutoff+1):s(3)), (Cutoff+1):s(3), threshold_2((Cutoff+1):s(3)), (Cutoff+1):s(3), threshold_3((Cutoff+1):s(3)))

ImageFiltered = invKLT_3D(clean_a_1_eigen_multip1,V);

end

function [clean_temp, Threshold] = Wavelet_Eig_Filt(a_I, m, wname, Variance, beta, multip)
%a_I = single(a_I); % 20230718
Wavelet_Level = 3;
[swa,swh,swv,swd]=swt2(a_I(:,:,m),Wavelet_Level,wname);
    sorh='s';
    % For subband - Horizontal Details
    Threshold(m, 0*Wavelet_Level+(1:Wavelet_Level)) = Wavelet2D_Shrinkage_Selection( swh, Variance, beta );
    % For subband - Vertical Details
    Threshold(m, 1*Wavelet_Level+(1:Wavelet_Level)) = Wavelet2D_Shrinkage_Selection( swv, Variance, beta );
    % For subband - Diagonal Details
    Threshold(m, 2*Wavelet_Level+(1:Wavelet_Level)) = Wavelet2D_Shrinkage_Selection( swd, Variance, beta );
    for j = 1:Wavelet_Level
        swh1(:,:,j)=wthresh(swh(:,:,j),sorh,Threshold(m, 0*Wavelet_Level + j)*multip);
        swv1(:,:,j)=wthresh(swv(:,:,j),sorh,Threshold(m, 1*Wavelet_Level + j)*multip);
        swd1(:,:,j)=wthresh(swd(:,:,j),sorh,Threshold(m, 2*Wavelet_Level + j)*multip );
    end
    clean_temp = iswt2(swa(:,:,end),swh1,swv1,swd1,wname);
end

