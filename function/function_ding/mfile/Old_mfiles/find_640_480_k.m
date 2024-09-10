
function k = find_640_480_k(fname);
a0 = imread(fname,'bmp'); a = double(a0);
[b0,y0]=background_640_img(fname,64,64,'bilinear') ;
b = reshape_640_img(a,b0,y0) ;
%b = ones(512,512);
%b(17:496,:) = a(:,64:575);
% b = b./lpfilter(b,0.03); %imagesc(b)
r = zeros(512,512);
[x,y]=meshgrid(1:512,1:512); mask = exp(-sqrt((x-257).^2+(y-257).^2)/300);
br = b.*mask ;
r2 = (imresize(br,0.125,'bicubic')); 
r(1:64,1:64) = r2;
rfft = abs(fftshift(fft2(r-mean(r(:))))); 
rfft(256:258,256:258)=0; rfft(:,257)=median(rfft(:)); rfft(257,:)=median(rfft(:)); 
rrt = xy2rt(rfft,257,257,1:128,0:0.01:2*pi); 
rsum = sum(rrt).*(0:127);
kr = peak1d(rsum) / 8;


bfft = abs(fftshift(fft2(b-mean(b(:))))); 
bfft(256:258,256:258)=0; bfft(:,257)=median(bfft(:)); bfft(257,:)=median(bfft(:)); 
brt = xy2rt(bfft,257,257,1:64,0:0.01:2*pi); 
bsum = sum(brt).*(0:63);
k = peak1d(bsum);
%figure(1),subplot(2,2,1), imagesc(b) ,   subplot(2,2,2),imagesc(bfft(257-64:257+63,257-64:257+63)) , subplot(2,2,3),plot(bsum)
%figure(2),subplot(2,2,1), imagesc(r) ,   subplot(2,2,2),imagesc(rfft(257-64:257+63,257-64:257+63)) , subplot(2,2,3),plot(rsum), subplot(2,2,4), imagesc(br)




