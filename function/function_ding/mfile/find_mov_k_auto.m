% Find the k of a movie, the movie should be 128*128, properly reshaped,
% better from reshape_128_128_112103
% [k0,std] = find_mov_k(a0);, k0 is the ks, std is the standard
% deviation

function [k0,k_std] = find_mov_k_auto(fname);

a0 = readin_160_120_file(fname);
a0 = reshape_128_128_112103(a0,'bilinear');

a = zeros(512,512);
a_size = size(a0);
for i=1:a_size(3)
    b = a0(:,:,i);          b = b - mean(b(:));
    a(101:100+a_size(1),101:100+a_size(2)) = b;
    afft = abs(fftshift(fft2(a))); 
    fft_rt = xy2rt(afft,257,257,1:200,pi/360:pi/180:2*pi);%imagesc(fft_rt), size(fft_rt)
    fft_r = sum(fft_rt,1).*(1:200); %size(fft_r)
    k0(i) = (peak1d(fft_r(10:100))+9)/(512/a_size(1)) ;
%   i, pause(0.001)
end
    %k = (29+median(k0))/(512/a_size(1));
    k_std = std(k0)/(512/a_size(1));
return