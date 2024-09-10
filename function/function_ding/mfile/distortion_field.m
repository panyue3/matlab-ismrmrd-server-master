% This is to plot the vector field of the lattice distortion of the
% hexagonal pattern. First find the peak position and then the peak
% position of the undistorted pattern and then find the difference and
% plot them.
% function [ px_re,py_re,px,py,cenx,ceny]=distortion_field(a)

function [ px_re,py_re,px,py,cenx,ceny,theta0,theta1,theta2]=distortion_field(a)
%a = a.*((sqrt( (x-65).^2 +(y-68).^2 )<58));
[x,y] = meshgrid(1:512,1:512);
a = a-mean(a(:));
%a = a0(:,:,ai);                      
% Do FFT of the image in a 512*512 domain.
b = zeros(512,512);                 b(101:228,101:228)=a;
a_fft = abs(fftshift(fft2(b)));      %imagesc(abs(a_fft)), pause
fft_rt = xy2rt(a_fft,257,257,1:200,0:pi/180:2*pi-0.001);% imagesc(abs(fft_rt)),pause
fft_r = sum(abs(fft_rt(:,40:60)));
k0 = 39 + peak1d(fft_r);
% Make a ring like mask around r = k0 and apply it
r0 = sqrt( (x-257).^2 + (y-257).^2 );
a_fft_abs = abs(a_fft).*( r0 > k0-5 ).*( r0 < k0+5 );
% Find the highest peak in the a_fft
max_fft = max(a_fft_abs(:)) ;
[kx,ky] = find(a_fft_abs == max(a_fft_abs(:)) );
[kxr,kyr] = peak2d(a_fft_abs(kx(1)-7:kx(1)+7,ky(1)-7:ky(1)+7));
kxr = kxr+kx(1)-8; kyr = kyr+ky(1)-8;
% The x and y are flipped in the matrix in Matlab, that is why the
% definition of theta here is atan(kx/ky) insteat of atan(ky/kx)
areal = real(a_fft(kx(1),ky(1)));   phi_0 = angle(a_fft(kx(1),ky(1))); theta_0 = atan((kxr-257)/(kyr-257));
% Make this peak and the peak complex conjugate to it zero
a_fft_abs(kx(1)-7:kx(1)+7,ky(1)-7:ky(1)+7)=0; 
kxc = 514-kx(1); kyc = 514-ky(1);
a_fft_abs(kxc-7:kxc+7,kyc-7:kyc+7)=0; 
% Find the highest peak in the remaining a_fft
max_fft = 0; max_fft = max(a_fft_abs(:)) ;
[kx1,ky1] = find(a_fft_abs == max_fft(1));
[kx1r,ky1r] = peak2d(a_fft_abs(kx1(1)-7:kx1(1)+7,ky1(1)-7:ky1(1)+7));
kx1r = kx1r+kx1(1)-8; ky1r = ky1r+ky1(1)-8;
a1real = real(a_fft(kx1(1),ky1(1)));   phi_1 = angle(a_fft(kx1(1),ky1(1))); theta1 = atan((kx1r-257)/(ky1r-257)); 
% Find the highest peak in the remaining a_fft, first make the second peak
% value zero.
a_fft_abs(kx1-7:kx1+7,ky1-7:ky1+7)=0;
kx1c = 514-kx1; ky1c = 514-ky1;
a_fft_abs(kx1c-7:kx1c+7,ky1c-7:ky1c+7)=0;%close all,figure(1),imagesc(a_fft_abs), pause(5),break

%max_fft = 0; max_fft = max(a_fft_abs(:)) ;
[kx2,ky2] = find(a_fft_abs == max(a_fft_abs(:)));
[kx2r,ky2r] = peak2d(a_fft_abs(kx2(1)-7:kx2(1)+7,ky2(1)-7:ky2(1)+7));
kx2r = kx2r+kx2(1)-8; ky2r = ky2r+ky2(1)-8;
a2real = real(a_fft(kx2(1),ky2(1)));   phi_2 = angle(a_fft(kx2(1),ky2(1)));theta2 = atan((kx2r-257)/(ky2r-257));pause(1)%,break

% Reconstuct the image 
x=0; y=0; [x,y]=meshgrid(1:128,1:128);r0 = sqrt( (x-65).^2 + (y-65).^2 );
k0 = (2*pi/128)*k0/4 ;

%recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 ); 
%figure(2),imagesc(recon); figure(1),imagesc(a)
if (abs(theta1-theta_0)<pi/3+0.2) & (abs(theta1-theta_0)>pi/3-0.2),
    if theta1 > theta_0; theta_1 = theta_0 + pi/3; theta_2 = theta_0 - pi/3;
    else theta_1 = theta_0 - pi/3; theta_2 = theta_0 + pi/3;
    end
else
    if theta2 > theta_0; theta_2 = theta_0 + pi/3; theta_1 = theta_0 - pi/3;
    else theta_2 = theta_0 - pi/3; theta_1 = theta_0 + pi/3;
    end
end
theta0 = theta_0;% theta_1 = theta_1, theta_2 = theta_2,
%recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 ); 
%figure(3),imagesc(recon); 

%'finished'
% The reconstruct image still has a shift from the real image, so I need to
% shift it to find the best fit. Because the amplitude nd the angle of the
% k I found is very precise. There is no need to rotate the reconstruct
% image.
x0=0;y0=0;val = 0;% theta_1=theta_0+2*pi/3; 
% a=0; a = a0(:,:,1); a = a- mean(a(:));
for x0=1:11; for y0=1:11
        x=0;y=0;[x,y]=meshgrid(-5+x0:122+x0,-5+y0:122+y0);
        recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
        recon = recon - mean(recon(:));
        val(x0,y0) = sum(sum(recon.*a.*(r0<15)));
end,end
[x00,y00] = find(val == max(val(:)));
x0=0;y0=0;i=0;j=0;val=0;
for x0=x00-1:0.2:x00+1;
    i=i+1; j=0;
    for y0=y00-1:0.2:y00+1
        j=j+1;
        x=0;y=0;[x,y]=meshgrid(-5+x0:122+x0,-5+y0:122+y0);
        recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
        recon = recon - mean(recon(:));
        val(i,j) = sum(sum(recon.*a.*(r0<15)));
    end,end
[x0,y0] = peak2d(val); x00 = x0*0.2+x00-1.2; y00 = y0*0.2+y00-1.2;
%'1'
% Find the rotation center. It better be found from the reconstruct image
% than from the real image. Because there is less noise, better resolution.
% I don't need much, 0.1 pixel will be much more than good.
[x,y] = meshgrid(-5+x00+63:0.1:-5+x00+65,-5+y00+63:0.1:-5+y00+65);
recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
% Find where is the center, the [cenx ceny] is the center;
[xc,yc] = peak2d(-recon);
cenx = 64 + (xc-1)*0.1; ceny = 64 + (yc-1)*0.1;
[x,y]=meshgrid(-5+x00:122+x00,-5+y00:122+y00);
recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
%figure(1),imagesc(recon);figure(2), imagesc(a)
clear x*, clear y*, 
clear k*, clear i, clear j, clear k,clear b, clear f*, clear a_*,clear p*,clear *real,
%'2'
% Get the mask, The way to get it is to get the first 0.2%(32 points in 128*128 images) of the highest
% peak value, find the median as the reference
mask_0 = 0;
a1d = sort(-a(:));
max_a = - median(a1d(1:32));
mask = (a>0.09*max_a).*(recon>0.5*max(recon(:))); %imagesc((recon>0.5*max(recon(:)))), figure(2), imagesc(a>0.09*max_a),,figure(3), imagesc(mask),pause,

% Find each individual peak and then make that small area zero, dispear
% from the mask
i = 0;px=0;py=0;
while sum(mask(:))>0.5
    i = i+1;
    x0 =0; y0 = 0;x=0;y=0;
    a_mask = a.*mask ;
    [x,y] = find(a_mask == max(a_mask(:)));
    x0 = x(1); y0 = y(1);
    x_low = max(1,x0-5); x_high = min(128,x0+5);
    y_low = max(1,y0-5); y_high = min(128,y0+5);
    [px(i),py(i)] = peak2d(a(x_low:x_high,y_low:y_high));
    px(i) = px(i) + x_low -1; py(i) = py(i) + y_low -1;
% This is the peak in the reconstructed pattern    
    [px_re(i),py_re(i)] = peak2d(recon(x_low:x_high,y_low:y_high));
    px_re(i) = px_re(i) + x_low -1; py_re(i) = py_re(i) + y_low -1;
    
    mask_0 = imfill(logical(1-mask),[x0 y0],4);
    mask = 1 - double(mask_0);  % figure(1),imagesc(mask), pause(1)
end
'finished'
%close all hidden
%hold on
%for n=1:i
%plot_arrow( px_re(n),py_re(n),px(n),py(n),'linewidth',0.2,'headwidth',0.5,'headheight',0.6 );
%end
%hold off

theta0, theta1,theta2,









