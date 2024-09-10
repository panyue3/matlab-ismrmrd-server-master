
function [Cutoff, Variance, SNR, N_std_map, p_value] = MP_Law_NoiseVariance_3D(data)
% This is a function to estimate the noise variance in 3D image using the MP Law.
% [Cutoff, Variance, SNR, gfactor, p_value] = MP_Law_NoiseVariance_3D(data);
% data: original data matrix [Nfe Npe frame]
% Cutoff: the number of noise-only eigenmode
% Variance: Noise variance
% SNR: Spatial mean SNR of the image series
% N_std_map: Noise std spatial map = a factor \times g-factor
% p-value: MP-law fitting p-value (must be very close to 1.0)
     
s = size(data);
%[V, D] = KL_Eigenvalue(data);
[eigImg, V, D] = KL_Eigenimage(data);
E = diag(D); %figure(4), hist(E, 24)
[Cutoff, Variance, ks, beta, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));

SNR = sqrt(max(E)/s(3))/sqrt(Variance);

%[a,V,D, eigImg] = KL_Eigenimage_NoMean(data);
%[eigImg, V, D] = KL_Eigenimage(data);

N_std_map = std(eigImg(:,:,1:Cutoff),0,3);