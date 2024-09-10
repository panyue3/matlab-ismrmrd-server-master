% function h = whetherhex(b);
% b is a 2-D arrey, from a movie

function h = whetherhex(b);

s = size(b);
if s(1)<s(2), l = floor(s(1)/2)-2; else l = floor(s(2)/2)-2; end
m1 = floor(s(1)/2)+1; m2 = floor(s(2)/2)+1;
a = ones(s(1),s(2)); a = b(:,:,1);
k0 = floor(roughk(a));        

[x,y]=meshgrid(1:s(1),1:s(2));
thex = sin(2*pi*k0*x/s(1))+sin(2*pi*(-k0*x/2/s(1)+k0*y*1.732/2/s(2)))+sin(2*pi*(-k0*x/2/s(1)-k0*y*1.732/2/s(2)));
win = exp(-(((x-m1)/(m1)).^2+((y-m2)/(m2)).^2));
thex = thex.*win;
b = b.*win;
thexf = abs(fftshift(fft2(t))); 
thexfrt = xy2rt(tf,s(1)/2+1,s(2)/2+1,1:l,-pi:0.01:pi); 
sf = abs(fftshift(fft2(a)));
sfrt = xy2rt(sf,s(2)/2+1,s(1)/2+1,1:l,-pi:0.01:pi);
sfrt(:,1:3)=0; %imagesc(sfrt);

tff = fft2(thexfrt); sff = fft2(sfrt);size(sff);size(tff);
c = fftshift(real(ifft2(tff.*conj(sff))));
c1 = fftshift(real(ifft2(tff.*conj(tff))));
c2 = fftshift(real(ifft2(sff.*conj(sff))));
bad=find(isnan(c));
c(bad)=0;
h = max(c(:))/sqrt((max(c1(:))*max(c2(:))));


tff = fft2(tsqfrt); sff = fft2(sfrt);size(sff);size(tff);
c = fftshift(real(ifft2(tff.*conj(sff))));
c1 = fftshift(real(ifft2(tff.*conj(tff))));
c2 = fftshift(real(ifft2(sff.*conj(sff))));
bad = find(isnan(c));
c(bad) = 0;
sq = max(c(:))/sqrt((max(c1(:))*max(c2(:))));