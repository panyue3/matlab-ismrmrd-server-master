%addpath Z:\ding\matlab\033104
%close all hidden
%fname = '2290_5317_90_0_9';
%skip = 0;
%x00 = 59; y00 = 65; r02 = 100;

%[b0,y0] =  background_mov(fname,16,16,'bilinear');
%fid = fopen(fname,'r');

%for i=1:skip, a00=fread(fid,[160,120],'uchar');  end%

%for i=1:200:300
%    a00=fread(fid,[160,120],'uchar');  
%    a = reshape_128_img(a00,b0,y0);  
%    [y,x]=meshgrid(1:128,1:128); a = a.*(sqrt((x-x00).^2+(y-y00).^2)<57); 
%    imagesc(a);pause
%end
%fclose(fid)
%close all hidden

%close all, clear all,
%[x,y]=meshgrid(1:128,1:128);
%a = cos(0.5*x + 0.3567) + cos(-0.25*x + 0.5*0.866*y +0.8576); %+ cos(-0.25*x - 0.5*0.866*y +0.1576);
%a_fft= fftshift(fft2(a));%%%

%angle(a_fft(65,55))
%a_fft(56,70)

%angle(a_fft(56,70))

%figure(1), imagesc(a>1.9),figure(2),imagesc(abs(a_fft))

%c = clock; c(6), meshgrid(1:128,1:128);meshgrid(1:128,1:128);meshgrid(1:128,1:128);meshgrid(1:128,1:128);meshgrid(1:128,1:128);c = clock; c(6),
%cc = clock; cc(5:6)
%c= zeros(1,170);
%cenx = 59; ceny = 65;
%for i=1:170,
%    px0 = x(:,i); py0 = y(:,i);
    %px0 = px2270(:,i); py0 = py2270(:,i);
%    px = px0(find(px0>0)); py = py0(find(px0>0));
%    n = length(px);
%    b = ones(1,n);
%    c0 = try_2(b,px,py);
    
%    c(i) = c(i) + c0;
    
    %break
    %end
%cc = clock; cc(5:6)
%close all hidden, plot(c),median_c = median(c(:)),% c2270=c;

%[x,y] = meshgrid(1:128,1:128);
%mask = ((x-66).^2 + (y-66).^2 )< 3160;
%skip = 10;
%fname  = '2238_5197_90_0_0';
%[b0,y0] =  background_mov(fname,16,16,'bilinear');
%fid = fopen(fname,'r');
%for i=1:skip, a00=fread(fid,[160,120],'uchar');  end; 
%for i=1:1,a00=fread(fid,[160,120],'uchar');
%a = reshape_128_img(a00,b0,y0); 
%figure(1),imagesc(a); axis xy, axis image,
%figure(2), imagesc(a.*mask + 0.01*(1-mask)),axis xy, axis image, pause(0.01)
%end
% fclose(fid)


%fname = '2275_5283_90_0_0'
%[px2275,py2275,px_re2275,py_re2275]=find_033104_peak_position(fname);
%c2275=0;
%for i=1:301, px0 = px2275(:,i); py0 = py2275(:,i); 
%    px = px0(find(px0>0)); py = py0(find(px0>0));
%    n = length(px);b = ones(1,n);
%    c0 = try_2(b,px,py);
%    c2275(i) =  c0;
%end


%fname = '2280_5294_90_0_0'
%[px2280,py2280,px_re2280,py_re2280]=find_033104_peak_position(fname);
c2280=0;
for i=1:301, px0 = px2280(:,i); py0 = py2280(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2280(i) =  c0;
end

fname = '2270_5271_90_0_0'
[px2270,py2270,px_re2270,py_re2270]=find_033104_peak_position(fname);
c2270=0;
for i=1:301, px0 = px2270(:,i); py0 = py2270(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2270(i) =  c0;
end


