% lpfilter(b, lo) b is a 2-D matrix, lo is  ratio, 0 < lo < 1 
% Only for real data

function [a]=lpfilter(b,lo)

[sx,sy] = size(b);
b = double(b);
sx2 = sx/2; sy2 = sy/2;
lox = (lo*sx2)^2;
loy = (lo*sy2)^2;

mb=mean(b(:));
a=fftshift(fft2(b-mb));

[x,y]=meshgrid(-sy/2:sy/2-1,-sx/2:sx/2-1);

z = exp(-(x.^2/lox+y.^2/loy)) ; 
a = a.*z;

a=real(ifft2(ifftshift(a)))+mb;

