% lpfilter1: Low pass filter 1-D array using Gaussian.
% b = lpfilter1(b,lo), 0<lo<1


function [a]=lpfilter1_boxcar(b,lo)

s = length(b);
b = double(b);
s2 = s/2; 
lox = (lo*s2)^2;

mb=mean(b(:));
a=fftshift(fft(b-mb));

x =-s/2:s/2-1;
%z = exp(-(x.^2/lox)) ; 
z = (abs(x)/max(abs(x)) < lo) ;
a = a.*z;

a=real(ifft(ifftshift(a)))+mb;
















