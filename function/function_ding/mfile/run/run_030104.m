addpath 121303
fid = fopen('1458_3385_90_0_32','r');a=0; %for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 
'Reading in files ...'
for i=1:100,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
'finished readin, reshaping ...'
a0 = reshape_128_128_112103(a,'bicubic'); a=0;%imagesc(a0(:,:,1)), break
'reshape finished'
x=meshgrid(1:60,1:360);  
clear ans, clear i, clear x,clear fid,clear a;break
a1 = 0; a1 =  sum(a0,3); asize = size(a0);a1=zeros(128,128); a2 =a1;a=0; %imagesc(a1), break
for i=1:asize(3) 
  
    b(1:360,1:60)=(xy2rt(a0(:,:,i),64.5,65.5,1:60,0:pi/180:2*pi-0.0001));b=b.*x;%figure(4),imagesc(b(:,:));pause(0.1);
    
%    bnew = b; 
%    for j=1:126
        bnew(1:360,1:60) = b(360:-1:1,1:60); %figure(1);imagesc(bnew);figure(2), imagesc(b), pause
%       b = bnew(1+mod((j):(359+j),360),1:60);
%    b0 = sum(b(1:360,6:8),2);    b1 = sum(b(1:360,13:20),2);      b2 = sum(b(1:360,24:32),2);
%        b00(1:360) = sum(b,2); 
%    b0_fft = fft(b0-mean(b0));   b1_fft = fft(b1-mean(b1));       b2_fft = fft(b2-mean(b2));
%    b0_r(i) = sum(real(b0_fft).^2)/sum(b0_fft.*conj(b0_fft));
%    b1_r(i) = sum(real(b1_fft).^2)/sum(b1_fft.*conj(b1_fft));
%    b2_r(i) = sum(real(b2_fft).^2)/sum(b2_fft.*conj(b2_fft));
%        b00fft = fft(b00-mean(b00)); asy0(j)=sum(sqrt((real(b00fft)).^2))/sum(abs(b00fft));
%    end
%    max_asy = max(asy0(:)); asy(i) = max_asy(1);asy0=0;
     b_corr =my_corr2(b,bnew); asy(i) = max(b_corr(:));
    i, pause(0.001)
end
plot(asy),max_asy= max(asy), mean_asy=mean(asy), std_asy=std(asy)
%figure(1), plot(b0_r), max(b0_r)
%figure(2), plot(b1_r), max(b1_r)
%figure(3), plot(b2_r), max(b2_r)
%a1=0; a1 = a0(:,:,100);a0 = 0; a0 = sum(a1(23:32,:),1); plot(a0)
%asize = size(a0);
%[x,y]=meshgrid(1:128,1:128); 
%for i=1:asize(3)
%    ai = a0(:,:,i);
%    [px,py]=gradient(ai);
%    [curlz,cav]=curl(x,y,px,py);
%    imagesc(curlz), axis xy, axis image,
%    M(i) = getframe; pause(0.01)
%    s(i) = sum(sum(curlz));
%end
%    movie(M)
%    figure(2), plot(s)

%for i=1:25;
%    ai = a0(:,:,i);
%    [x1,y1]=meshgrid(2:128,1:128);[y2,x2]=meshgrid(1:128,2:128);
%    a1(1:128,2:128) = x1.*diff(ai,1,2); 
%    a2(2:128,1:128) = y2.*diff(ai,1,1);
    %imagesc( a1-a2 );axis xy, axis image,
    %s(i)=sum(sum(a1-a2));
    %end
    %plot(s)
clear a;, clear fid, clear i,clear x*, clear y* clear s