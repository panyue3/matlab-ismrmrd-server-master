% lpfilter_complex(b, lo) b is a 2-D matrix, lo is  ratio, 0 < lo < 1 

function [a]=lpfilter_complex(b,lo)

[sx, sy] = size(b);
b = double(b);
sx2 = sx/2; sy2 = sy/2;
lox = (lo*sy2)^2;
loy = (lo*sx2)^2;

mb=mean(b(:));
a=fftshift(fft2(b-mb));

[x,y]=meshgrid(-sy/2:sy/2-1,-sx/2:sx/2-1);

z = exp(-(x.^2/lox+y.^2/loy)) ; %imagesc(z), colorbar
a = a.*z;

a=(ifft2(ifftshift(a)))+mb;

