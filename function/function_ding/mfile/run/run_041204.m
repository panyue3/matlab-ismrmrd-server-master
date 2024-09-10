%addpath 032404
%fid=fopen('2260_5248_90_0_4','r');for i=1:5, a(1:160,1:120,i)=fread(fid,[160,120],'uchar'); end; fclose(fid)
%a0 = reshape_128_128_112103(a,'bicubic');
%[x,y]=meshgrid(1:128,1:128);
%mask = sqrt((x-65).^2+(y-67).^2)<57; % imagesc(mask), pause
%%clock,
%[px,py,px_re,py_re] = find_mov_peaks_circle_insert(a0(:,:,1),mask);
c = clock; c(6)
alpha_1 = 1.8488;  alpha_2 = 3.0174 ; r0=12.42;
k11 = pi*r0*cos(0.8858)/64; k12 =r0*sin(0.8858)*pi/64; k21 = r0*cos(0.8858+pi*2/3)*pi/64; k22 = r0*sin(0.8858+pi*2/3)*pi/64;
% k11 = -0.6092; k12 = -0.0309; k21 = -0.6021; k22 = 0.0980;
de = k11*k22 - k12*k21;
k11,k12,
k21,k22,
n = 0;
for i = alpha_1-40*pi:2*pi :40*pi
for j = alpha_2-40*pi:2*pi :40*pi
    x0 = (i*k22 - j*k12)/de ;
    y0 = (j*k11 - i*k21)/de ;
    r2 = (x0-65)^2 + (y0-67)^2;
    if r2 < 3249
    n = n+1;
    x(n) = x0;
    y(n) = y0;
    end
end
end
c1 = clock; c1(6)
 plot(x,y,'*')
clear all


