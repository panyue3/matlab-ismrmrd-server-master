
function [Cutoff, Noise_Map, p_value] = MP_Law_Noise_Map_3D(data)
% This is a function to estimate the noise variance in 3D image using the MP Law.
% [Cutoff, Noise_Map, p_value] = MP_Law_Noise_Map_3D(data)
% data: original data matrix [Nfe Npe frame]
% Noise_Map: Spatial Map of Noise std

s = size(data);
[eigImg, V, D] = KL_Eigenimage(data);
E = diag(D); %figure(4), hist(E, 24)
[Cutoff, Variance, ks, beta, p_value, H] = KS_Cutoff_2Steps(E, s(1)*s(2));

Noise_Map = std(eigImg(:,:,1:Cutoff),0,3);

