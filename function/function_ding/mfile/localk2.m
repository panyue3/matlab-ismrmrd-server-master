% [k,kth] = localk2(a) a is the Fourier Transformation of a image. 
% k is the K field, kth is the direction field

function [kf,th] = localk2(a,lenperpix)

a1 = abs(a); [l,m] = size(a);
maxa = max(a1(:))
[y,x] = find(a1 > 0.618*maxa);
xc = floor(m/2)+1; yc = floor(l/2)+1;
kx = x - xc ; ky = y - yc ;

[y0,x0] = meshgrid(1:l,1:m);
n = length(x)
k = 0 ; kxy=0;kxx=0;kyy=0;kx0=0;ky0=0; 
for i = 1:n 
   k=imag(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0)+real(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0)+k ;
   kxx=kx(i)^2*(imag(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0)+real(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0))+kxx ;
   kyy=ky(i)^2*(imag(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0)+real(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0))+kyy ;
   kxy=-kx(i)*ky(i)*(imag(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0)+real(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0))+kxy ; 
   kx0=kx(i)*(imag(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0)-real(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0))+kx0 ; 
   ky0=ky(i)*(imag(a(y(i),x(i)))*cos(kx(i)*x0+ky(i)*y0)-real(a(y(i),x(i)))*sin(kx(i)*x0+ky(i)*y0))+ky0 ;
end

k2t = kxx + kyy ;
   % find roughly k0
cx0=floor(m/2)+1;
cy0=floor(l/2)+1;
b0rt=xy2rt(a1,cx0,cy0,1:cx0,-pi:0.01:pi);
b0sum=sum(b0rt);
k0 = find(b0sum == max(b0sum))

k2t = k2t./k;
%figure(2)
%img(k2t)
median(k2t(:))
k2t = clean(k2t,k0,0.382);
median(k2t(:))
k2 = sqrt(k2t);
kf = k2*2*pi/256/lenperpix;;

si = -sign(kxy./k);
th=atan2(si.*sqrt(ky0),sqrt(kx0));

