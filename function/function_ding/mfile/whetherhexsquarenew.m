% function [h , sq] = whetherhexsquare(b);
% b is a 2-D arrey, from a movie

function [h,sq] = whetherhexsquare(b);

s = size(b);
if s(1)<s(2), l = floor(s(1)/2)-2; else l = floor(s(2)/2)-2; end
m1 = floor(s(1)/2)+1; m2 = floor(s(2)/2)+1;
a = ones(s(1),s(2)); a = b(:,:,1);
k0 = floor(roughk(a)),        

[x,y]=meshgrid(1:s(1),1:s(2));
win = exp(-(((x-m1)/(m1)).^2+((y-m2)/(m2)).^2));
a = a.*win; 
sf = abs(fftshift(fft2(a)));
sfrt0 = xy2rt(sf,s(2)/2+1,s(1)/2+1,1:l,-pi:0.01:pi); sfrt0(:,1:3) = 0; 
if k0 > 3, k0min = k0 - 2 ; else k0min = k0; end
if k0 < m1-4 & k0 < m2-4, k0max = k0+2; else k0max = k0-1; end, 
if k0 ==1, k0min = 0, k0max = 2; end
k0min:k0max
sfrt = sum(sfrt0(:,k0min:k0max),2);
thexfrt = zeros(629,1) ; tsqfrt = zeros(629,1) ;
for i=0:5; b0 = 50 + i*105; thexfrt(b0:b0+1)=1; end,
for i=0:3; b0 = 50 + i*173; tsqfrt(b0:b0+1)=1; end, clear b0;

tf = fft(thexfrt); sf = fft(sfrt);size(sf);size(tf);
c = fftshift(real(ifft(tf.*conj(sf))));
c1 = fftshift(real(ifft(tf.*conj(tf))));
c2 = fftshift(real(ifft(sf.*conj(sf))));
bad=find(isnan(c));
c(bad)=0;
h = max(c(:))/sqrt((max(c1(:))*max(c2(:))));
c = 0; c1 = 0; c2 = 0;

tf = fft(tsqfrt); sf = fft(sfrt);size(sf),size(tf),
c = fftshift(real(ifft(tf.*conj(sf))));
c1 = fftshift(real(ifft(tf.*conj(tf))));
c2 = fftshift(real(ifft(sf.*conj(sf))));
bad = find(isnan(c));
c(bad) = 0;
sq = max(c(:))/sqrt((max(c1(:))*max(c2(:))));