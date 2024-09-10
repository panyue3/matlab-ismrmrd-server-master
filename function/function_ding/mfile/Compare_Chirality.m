% Try to compare the image with a standard image and find the chirality,
% but now this function is changed to first find the standard image and then from it generate a mask and and the peak of the image 
function chirality = Compare_Chirality(a)


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
a1real = real(a_fft(kx1(1),ky1(1)));   phi_1 = angle(a_fft(kx1(1),ky1(1))); theta_1 = atan((kx1r-257)/(ky1r-257));
% Find the highest peak in the remaining a_fft, first make the second peak
% value zero.
a_fft_abs(kx1-7:kx1+7,ky1-7:ky1+7)=0;
kx1c = 514-kx1; ky1c = 514-ky1;
a_fft_abs(kx1c-7:kx1c+7,ky1c-7:ky1c+7)=0;%close all,figure(1),imagesc(a_fft_abs), pause(5),break

%max_fft = 0; max_fft = max(a_fft_abs(:)) ;
[kx2,ky2] = find(a_fft_abs == max(a_fft_abs(:)));
[kx2r,ky2r] = peak2d(a_fft_abs(kx2(1)-7:kx2(1)+7,ky2(1)-7:ky2(1)+7));
kx2r = kx2r+kx2(1)-8; ky2r = ky2r+ky2(1)-8;
a2real = real(a_fft(kx2(1),ky2(1)));   phi_2 = angle(a_fft(kx2(1),ky2(1)));theta_2 = atan((kx2r-257)/(ky2r-257));%,break

% Reconstuct the image 
x=0; y=0; [x,y]=meshgrid(1:128,1:128);r0 = sqrt( (x-65).^2 + (y-65).^2 );
k0 = (2*pi/128)*k0/4 ;
%recon1 = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 ); 
%recon2 = a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
%figure(2),imagesc(recon1+recon2); figure(1),imagesc(a0(:,:,1))
%'finished'
% The reconstruct image still has a shift from the real image, so I need to
% shift it to find the best fit. Because the amplitude nd the angle of the
% k I found is very precise. There is no need to rotate the reconstruct
% image.
x0=0;y0=0;val = 0;
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

% Find the rotation center. It better be found from the reconstruct image
% than from the real image. Because there is less noise, better resolution.
% I don't need much, 0.1 pixel will be much more than good.
[x,y] = meshgrid(-5+x00+63:0.1:-5+x00+65,-5+y00+63:0.1:-5+y00+65);
recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
[xc,yc] = find(recon==min(recon(:)));
cenx = 64 + (xc-1)*0.1; ceny = 64 + (yc-1)*0.1;
[x,y]=meshgrid(-5+x00:122+x00,-5+y00:122+y00);
recon = areal*cos(k0*cos(theta_0)*x+k0*sin(theta_0)*y+phi_0)  +  a1real*cos(k0*cos(theta_1)*x+k0*sin(theta_1)*y+phi_1 )+a2real*cos( k0*cos(theta_2)*x + k0*sin(theta_2)*y +phi_2 );
%figure(1),imagesc(recon);figure(2), imagesc(a)

clear x*, clear y*, 
clear k*, clear i, clear j, clear k,clear b, clear f*, clear a_*,clear p*, clear t*,clear *real,

%a_rt  =xy2rt(a,ceny,cenx,1:60,0:pi/180:2*pi-0.001);
%re_rt =xy2rt(recon,ceny,cenx,1:60,0:pi/180:2*pi-0.001);
%for i=1:60
%    c = my_xcorr(a_rt(:,i),re_rt(:,i));
%    dev(i) = peak1d(c)-180; 
%end
%plot(dev,'*')
% This method may not work and my another idea is do the same thing to the
% image and its enantiomer
%a_rt_en = xy2rt(a,ceny,cenx,1:60,2*pi-0.001:-pi/180:0); figure(1),imagesc(a_rt_en),figure(2),imagesc(a_rt)
%for i=1:60
%    c = my_xcorr(a_rt(:,i),a_rt_en(:,i));
%    dev(i) = peak1d(c)-180; 
%end
% The method to compare the original image and its enantiomer doesn't work,
% now I try a new method, only count the peaks. The way to do it is to use
% the reconstructed pattern. Use it as a mask, then in side each hole there
% will be one individual peak. Find the peak position and then use the old
% algorithm to get the chirality.
mask_0 = 0;
mask = (a>0.09*max(a(:))).*(recon>0.5*max(recon(:)));
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
    mask_0 = imfill(logical(1-mask),[x0 y0],4);
    mask = 1 - mask_0; % figure(i),imagesc(mask), pause,close all,
end
    %plot(px,py,'*'),pause
    %b = ones(1,i)/i;
    %chirality = try_2(b,px,py) ;
    %clock,
    chirality = rot_chiral(cenx,ceny,px,py);
    %clock,
return