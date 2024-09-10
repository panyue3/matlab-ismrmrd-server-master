% Make a artificial hexagon and put it nto the image processing process to
% see if I can see any k difference in different raduis ring.
close all
[x,y] = meshgrid(1:512,1:512);

k0=30*2*pi/512;
k1=k0; k2x = k0*cos(2*pi/3); k2y = k0*sin(2*pi/3); k3x = k0*cos(-2*pi/3); k3y = k0*sin(-2*pi/3);
d1=pi/4;d2=pi/3;d3=pi/2;
a = cos(k1*x) + cos(k2x*x + k2y*y) + cos(k3x*x + k3y*y) ; 
b = cos(k1*x+d1) + cos(k2x*x + k2y*y+d1) + cos(k3x*x + k3y*y+d1) ;
c = cos(k1*x+d2/2) + cos(k2x*x + k2y*y+d2) + cos(k3x*x + k3y*y+3*d2/2) ;
d = -cos(k1*x+d3) + cos(k2x*x + k2y*y+d3) + cos(k3x*x + k3y*y+d3) ;
colormap(gray)
figure(1), subplot(2,2,1), imagesc(a), axis xy; axis image;  subplot(2,2,2), imagesc(b), axis image; axis xy;  subplot(2,2,3), imagesc(a>1), axis xy; axis image;  subplot(2,2,4), imagesc(b>1), axis xy;  axis image; %pause,
figure(2), colormap(gray), subplot(2,2,1), imagesc(c), axis xy; axis image;  subplot(2,2,2), imagesc(d), axis image; axis xy;  subplot(2,2,3), imagesc(c>1), axis xy; axis image;  subplot(2,2,4), imagesc(d>1), axis xy;  axis image; pause,
%a = cos(k2x*x + k2y*y)  ; imagesc(a)
j=0;
for i=0:pi/10:2*pi
    a00 = d * (sin(i+1)-sin(i));
    a00 = a00 + 0.1*a00.^2 + 0.2*a00.^3 ;
    a00 = a00.*( a00>median(a00(:)));
   j = j+1,
a0=zeros(512,512);
for m=1:5;
    a1 = a00;
    mask = sqrt((x-257).^2+(y-257).^2) < 50*m & sqrt((x-257).^2+(y-257).^2) > 50*(m-1) ; a1 = a1 .* mask + mean(a1(:)).*(1-mask);
    a2 = (imresize(a1,0.25,'bicubic')); a2m = mean(a2(:));
    a0 = a0*a2m ; a0(1:128,1:128)=a2;
    a_fft = abs(fftshift( fft2( a0) ));
    a_fft_rt = xy2rt(a_fft, 257,257,1:128, pi/360:pi/180:2*pi);
    a_fft_r = sum(a_fft_rt).*(1:128);
   [k_ring(j,m), width_ring(j,m)] = peak_1d_width(a_fft_r(26:128)); 
    % figure(1), subplot(2,2,1), imagesc(a1), subplot(2,2,2), imagesc(a_fft_rt), subplot(2,2,3), plot(a_fft_r), subplot(2,2,4), imagesc(mask), pause
    %m=m, i=i,theta=theta, pause(0.05)
end,end

 a1 = a;
    %mask = sqrt((x-257).^2+(y-257).^2) < 50*m & sqrt((x-257).^2+(y-257).^2) > 50*(m-1) ; a1 = a1 .* mask + mean(a1(:)).*(1-mask);
    a2 = (imresize(a1,0.25,'bicubic')); a2m = mean(a2(:));
    a0 = a0*a2m ; a0(1:128,1:128)=a2;
    a_fft = abs(fftshift( fft2( a0) ));
    a_fft_rt = xy2rt(a_fft, 257,257,1:128, pi/360:pi/180:2*pi);
    a_fft_r = sum(a_fft_rt).*(1:128);
   [k, width] = peak_1d_width(a_fft_r(26:128)),
% k_ring
figure(2), plot(k_ring)
