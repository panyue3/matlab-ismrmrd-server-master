% find angle in k space, [angle,phi] = findang(a,n) a is the image, n
% is the number of peak you want to find;
% phi is the phase

function [ang,phi] = findang(a,n);

k0=roughk(a);
b = abs(fftshift(fft2(a)));
b0 = fftshift(fft2(a));
mn = mean(b(:));
[x0,y0] = size(b);
[x1,y1] = meshgrid((-x0+1)/2:(x0-1)/2,(-y0+1)/2:(y0-1)/2);
r = sqrt(x1.*x1+y1.*y1);
c = ( r > k0*0.8 & r < k0 * 1.2 );
b = b.*c ;

%figure(10)
%img(b)
%title('img before angle')

[x9,y9]=meshgrid(1:9,1:9);
c9 = x9*0+mn;
if mod(x0,2) == 0, xc = x0/2 + 1 ; else xc = (x0+1)/2; end
if mod(y0,2) == 0, yc = y0/2 + 1 ; else yc = (y0+1)/2; end

for i =1:n
x=0;y=0;
maxb = max(b(:));
[y,x]=find(b == maxb);
if x(1)==xc, ang(i)=(y(1)-yc)/abs(y(1)-yc)*pi/2;
else ang(i) = atan((y(1)-yc)/(x(1)-xc));
end
phi(i) = atan(imag(b0(y(1),x(1)) )/real(b0(y(1),x(1)) ));

%b(y(1)-4:y(1)+4,x(1)-4:x(1)+4) = c9; 
%b(2*yc-y(1)-4:2*yc-y(1)+4,2*xc-x(1)-4:2*xc-x(1)+4) = c9;
end
% figure(9)
%img(b);
%title('img after finding angle')
