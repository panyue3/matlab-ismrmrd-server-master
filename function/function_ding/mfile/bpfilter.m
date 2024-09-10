% bpfilter(b, lo, hi) b is a 2-D matrix, lo and hi are ratios, 0 < lo < hi < 1 

function [a]=bpfilter(b,lo,hi)

[sx,sy] = size(b);
b = double(b);
hix = hi*hi*sx*sx/4; 	hiy = hi*hi*sy*sy/4;
lox = (lo*lo*sx*sx)/4;  loy = (lo*sy*lo*sy)/2;

mb = mean(b(:));
a = fftshift(fft2(b - mean(b(:))));
[x,y]=meshgrid(-sy/2:sy/2-1,-sx/2:sx/2-1);

zhi = exp(-(x.^2/hix+y.^2/hiy)) ;
zlo = exp(-(x.^2/lox+y.^2/loy)) ;

a = a.*zlo.*(1-zhi);                % figure(3), imagesc(zlo.*(1-zhi))
a=real(ifft2(ifftshift(a)))+mb;
