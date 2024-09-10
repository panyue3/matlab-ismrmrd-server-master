% Find the peak position of each indvidule peak in the pattern, return the
% position of the peaks and the position of the center. This is only good
% for the data of the circlur insert. So, the center is on one of the
% peaks. [px,py,cenx,ceny] = find_mov_peaks_circle_insert(a,mask) ; a is the
% input image, must be 128*128, already reshaped.

function [px,py,px_re,py_re] = find_mov_peaks_circle_insert(a,x00,y00,r02)

%a = a-mean(a(:));
%a = bpfilter(a,0.618,0.0618);
%a_fft = (fftshift(fft2(a)));      
%[x_temp,y_temp]=find(abs(a_fft)==max(abs(a_fft(:))));
%x_1 = round(x_temp(1));                        y_1 = round(y_temp(1));
%r = sqrt((x_1-65)^2+(y_1-65)^2);%

%ang_1 = ang(x_1-65,y_1-65); 
%x_2 = round(65 + r*cos(ang_1+2*pi/3));         y_2 = round(65 + r*sin(ang_1+2*pi/3));
%x_3 = round(65 + r*cos(ang_1-2*pi/3));         y_3 = round(65 +
%r*sin(ang_1-2*pi/3));%%

%mask_0 = zeros(128);
%mask_0(x_1,y_1)=1;
%mask_0(x_2,y_2)=1;
%mask_0(x_3,y_3)=1;
%mask_0(130 - x_1,130 - y_1)=1;
%mask_0(130 - x_2,130 - y_2)=1;
%mask_0(130 - x_3,130 - y_3)=1; 
%a_fft = a_fft./(abs(a_fft));
%b = abs(ifft2(a_fft.*mask_0));  recon = b;
%b = b>0.65*max(b(:));
%mask = mask.*b; % imagesc(mask)
%a =a-min(a(:));
%i = 0;px=0;py=0;
%while sum(mask(:))>0.5
%    i = i+1;
%    x0 =0; y0 = 0;x=0;y=0;
%    a_mask = a.*mask ;
%    [x,y] = find(a_mask == max(a_mask(:)));
%    x0 = x(1); y0 = y(1);
%    x_low = max(1,x0-5); x_high = min(128,x0+5);
%    y_low = max(1,y0-5); y_high = min(128,y0+5);
%    [px(i),py(i)] = peak2d(a(x_low:x_high,y_low:y_high));
%    px(i) = px(i) + x_low -1; py(i) = py(i) + y_low -1;
% This is the peak in the reconstructed pattern    
%    [px_re(i),py_re(i)] = peak2d(recon(x_low:x_high,y_low:y_high));
%    px_re(i) = px_re(i) + x_low -1; py_re(i) = py_re(i) + y_low -1;
%    
%    mask_0 = imfill(logical(1-mask),[x0 y0],4);
%    mask = 1 - double(mask_0);  % figure(1),imagesc(mask), pause(0.1)
%end
%'finished'

[y,x]=meshgrid(1:128,1:128);  a = a.*(((x-x00).^2+(y-y00).^2)<r02)+ min(a(:))*(((x-x00).^2+(y-y00).^2)<r02);
a = a-mean(a(:));             a = bpfilter(a,0.618,0.0618);        %figure(1), hist(a(:),50)
a_fft = (fftshift(fft2(a)));      
[x_temp,y_temp]=find(abs(a_fft)==max(abs(a_fft(:))));
x_1 = round(x_temp(1));                        y_1 = round(y_temp(1)); % figure(3),imagesc(a),axis xy, 
% alpha_1 = angle(a_fft(x_1,y_1)); 

[x0,y0] = peak2d(abs(a_fft(x_1-3:x_1+3,y_1-3:y_1+3)));   x0 = x0(1) + x_1-4; y0 = y0(1) + y_1-4;
r = sqrt((x0-65)^2+(y0-65)^2);  theta = ang(x0-65,y0-65);
x_1 = x0; y_1 = y0;

x_temp = round(65 + r*cos(theta + 2*pi/3)); y_temp = round( 65 + r*sin(theta + 2*pi/3) );
[x02,y02] = peak2d(abs(a_fft(x_temp-3:x_temp+3,y_temp-3:y_temp+3)));   x_2 = x02(1) + x_temp-4; y_2 = y02(1) + y_temp-4;

%x_2 = 65 + r*cos(theta + 2*pi/3);   x0 = round(x_2);y_2 = 65 + r*sin(theta + 2*pi/3);   y0 = round(y_2);

%[x_temp,y_temp]=find(abs(a_fft)==max(max(abs(a_fft(x0-2:x0+2,y0-2:y0+2)))));

%x_temp(1),x_1, y_temp(1),y_1 ;alpha_2 = angle(a_fft(x_temp(1),y_temp(1)));
k11 = (x_1-65)*pi/64;
k12 = (y_1-65)*pi/64;
k21 = (x_2-65)*pi/64;
k22 = (y_2-65)*pi/64;

%figure(2),imagesc((cos(k11*x+k12*y)+cos(k21*x+k22*y))>1.8)
%k11^2+k12^2,
%k21^2+k22^2,
% alpha_1, alpha_2, r02; 
b=zeros(128,128);
[a_x, a_y] = peak2d(a(x00-2:x00+2,y00-2:y00+2));
a_x = a_x(1) + x00 - 3; a_y = a_y(1) + y00 - 3 ;
alpha_1 = ( k11 * a_x + k12* a_y);   alpha_2 = ( k21 * a_x + k22* a_y);
de = k11*k22 - k12*k21;
n = 0;
for i = alpha_1-30*pi:2*pi :alpha_1+30*pi
for j = alpha_2-30*pi:2*pi :alpha_2+30*pi
    x0 = (i*k22 - j*k12)/de ;
    y0 = (j*k11 - i*k21)/de ;
    r2 = (x0-x00)^2 + (y0-y00)^2;
    if r2 < r02
    n = n+1;
    xo(n) = x0; 
    yo(n) = y0; b(round(x0),round(y0))=10; x_try(n) = round(x0);y_try(n) = round(y0);
    end
end, end ; 
%plot(yo,xo,'*'),pause
%imagesc(b); n = n, plot(y_try,x_try,'*r'); hold off
%[a0,b0] = find(my_corr2(a,b)==max(max(my_corr2(a,b))));
x_new = zeros(n,1); y_new = zeros(n,1);
for i=1:n
    x0 = round(xo(i));  y0 = round(yo(i));  
    x_min = max(x0-6,1); x_max = min(128,x0+6); y_min = max(y0-6,1); y_max = min(128,y0+6);
    a0 = a(x_min:x_max,y_min:y_max);a0 = a0 - min(a0(:));%max_a0 = max(a0(:)), median_a0 = median(a0(:)),pause
    
    if max(a0(:))<2*median(a0(:)), x_new(i) = x0; y_new(i)=y0;
    else
    [y,x] = meshgrid(y_min:y_max,x_min:x_max); win = exp(-((x-x0).^2+(y-y0).^2)/20);  %subplot(2,2,1),imagesc(win);
    a0 = a0.*win;                                                                     %subplot(2,2,2),imagesc(a0);
    [x0,y0] = find(a0 == max(a0(:))); x0 = round(x0(1)+x_min-1); y0 = round(y0(1)+y_min-1);
    x_min = max(x0-3,1); x_max = min(128,x0+3); y_min = max(y0-3,1); y_max = min(128,y0+3);
    [x_temp, y_temp] = peak2d(a(x_min:x_max,y_min:y_max));% subplot(2,2,3),imagesc(a0);subplot(2,2,4),imagesc(a(x_min:x_max,y_min:y_max)),colorbar,pause(1)
    % x_temp,x_min
    x_new(i) = x_min - 1 + x_temp(1);
    y_new(i) = y_min - 1 + y_temp(1);
    %hold on, plot(x_new(i),y_new(i),'*'), pause
    %x_new(i) =  x_temp(1);  y_new(i) =  y_temp(1);
    end
    %if i==65, x0,y0, x_new(i), y_new(i),imagesc(a0),pause,end
end

px = x_new; py = y_new; px_re = xo(1:n); py_re = yo(1:n);
% figure(1), plot(py,px,'*',py_re,px_re,'d'), figure(2),hold on, plot(py_re, px_re,'d'), hold off, 