clear all
close all hidden

[x,y] = meshgrid(0:255);
x = x/256 ; y = y / 256;
b=sin(x.*2*pi*20.*(1+0.05.*sin(4*pi*x))*sin(pi/6)+y.*2*pi*20.*(1+0.05.*sin(2*pi*y))*cos(pi/6));
%b = sin(2*pi*x.*10.*(1+0.1*sin(2*pi*y)) );
%b = sin(2*pi*x*10);
figure(1)
imagesc(b)

%b = b-mean(b(:));
a = b;lenperpix = 1/256;[l,m]=size(b);
[dx,dy] = gradient(a);
[dxx,d0xy] = gradient(dx);
[d0yx,dyy] = gradient(dy); 
kx =1/ (lenperpix*lenperpix)*dxx(2:l-1,2:m-1) ;
ky = 1/(lenperpix*lenperpix)*dyy(2:l-1,2:m-1) ;
dxy = 1/(lenperpix*lenperpix)*(d0xy(2:l-1,2:m-1)+d0yx(2:l-1,2:m-1))/2;

%[kx,ky]=diff2(b,1/256);
%figure(2)
%img(kx)
%title('kx')
%colorbar
a = b(2:255,2:255);
kx = kx./a;
ky = ky./a;

kf1 = kx+ky;
kf1 = (1-((kf1) > 0)).*kf1;
kf = sqrt(-kf1);
figure(2)
img(kf)

kff = clean(kf,20,0.1);
kff = lpfilter(kff,0.25,0.26);
%kff =kf;
figure(3)
img(kff)
colorbar

k1 =sqrt((2*pi*20.*(1+0.5.*sin(4*pi*x))*sin(pi/6)).^2 +(2*pi*20.*(1+0.5.*sin(2*pi*y))*cos(pi/6)).^2);
%k1 = (2*pi*10.*(1+0.1*sin(2*pi*y)) );
%k1 = 10*ones(size(b));
k0 = k1(2:255,2:255);  
%k0 = 2*pi*10;
figure(4)
img(k0)
colorbar

kp = (kff-k0).*(kff-k0)./k0./k0;
 
[l,m] = size(kff);

msr = sqrt(sum(kp(:))/l/l)*100 

