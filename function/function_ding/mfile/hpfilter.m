% hpfilter(b, hi) b is a 2-D matrix, hi is ratio, 0 < hi < 1 

function [a]=hpfilter(b,hi)

[sx,sy] = size(b);
b = double(b);
hix = hi*hi*sx*sx/4; hiy = hi*hi*sy*sy/4;

mb = mean(b(:));
a = fftshift(fft2(b - mean(b(:))));
[x,y]=meshgrid(-sy/2:sy/2-1,-sx/2:sx/2-1);

z = exp(-(x.^2/hiy+y.^2/hix)) ;
a = a.*(1-z);
%figure(2); imagesc(abs(1-z));
%surf(1-z) 
a = real(ifft2(ifftshift(a))) + mb;

