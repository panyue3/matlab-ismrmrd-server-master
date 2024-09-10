% [b,c] = decon(a,startang,endang) a is the input image b is the output
% imgage. startang is the starting angle of the mask, endang is the end
% angle c is thew image after decon before Gaussian window.

function [b,c] = decon(a,startang,endang,rotation);

a1 = a - mean(a(:));
a1 = fftshift(fft2(a1));

if startang > pi/2, startang = startang - pi; end;
if endang > pi/2, endang = endang-pi; end;
if startang < -pi/2, startang = startang + pi; end;
if endang < -pi/2, endang = endang + pi; end;

[x0,y0] = size(a1);
[x,y] = meshgrid(0.5*(1-x0):0.5*(x0-1),0.5*(1-y0):0.5*(y0-1));
if startang > endang
z = ( startang <(atan(y./x)+rotation) | endang > (atan(y./x)+rotation) );
else
z = ( startang <(atan(y./x)+rotation) & endang > (atan(y./x)+rotation) );
end
a1 = a1.*z ;
c = a1 ; 
a2 = abs(a1);

x = 0; y =0 ; z = 0;
[x,y] = meshgrid(1:x0,1:y0);
if mod(x0,2) == 0, xc = x0/2 + 1;  else xc = (x0+1)/2 ; end
if mod(y0,2) == 0, yc = y0/2 + 1;  else yc = (y0+1)/2 ; end
maxa = max(a2(:));
%[y1,x1] = find(a2 == maxa);
[x1,y1] = fit2d(a2)
if length(y1) > 2;
'Warning: Error in decon'
end
x2 = 2*xc - x1(1) ; y2 = 2*yc - y1(1); 

r2 = (x1(1)-xc)^2+(y1(1)-yc)^2; r0 = sqrt(r2);
z = exp(-8*((x-x1(1)).^2 + (y-y1(1)).^2)/r2)+exp(-8*((x-x2).^2+(y-y2).^2)/r2);
zc = (sqrt((x-xc).^2+(y-yc).^2) > 0.9*r0 & sqrt((x-xc).^2+(y-yc).^2) <1.1*r0 );
a1 = a1.*z;
c = c.*zc;

b = a1 ;
c = real(ifft2(ifftshift(c)));
b = real(ifft2(ifftshift(b)));

