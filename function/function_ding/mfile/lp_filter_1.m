% lp_filter_1: Low pass filter 1-D array using flat filter plus a Gaussian smooth edge.
% b = lp_filter_1(b,r,sigma), 0<r,sigma<1, r is the cutoff frequency scaled
% by the max frequency, sigma is the half-height width of Gaussian edge


function [a]=lp_filter_1(b,r,sigma)

s = length(b);
b = double(b);
s2 = s/2; 
lox = (r*s2);
sig = (sigma*s2)^2;

mb=mean(b(:));
a=fftshift(fft(b-mb));
z = zeros(size(a));

x =-s/2:s/2-1;

z = (abs(x)<=lox) +(abs(x) > lox).*exp(-(( abs(x)- lox).^2/sig)) ;  sig%size(a),size(z), plot(z,'*-'), pause
% make the size of a and z the same size
if prod(double(size(a)==size(z))),
    a = a.*z;
else
    a = a.*z';
end
a=real(ifft(ifftshift(a)))+mb;


