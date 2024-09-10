% Find k more precisely

function [k] = ftrans(fname);
  a = imread(fname); % a1 = imread(fname1);
%  a = (double(a))./(1+double(a1)); 
% figure(2); imagesc(a);colormap(gray);
  b(1:480,1:480) = a(1:480,65:544);
%  c0 = a(:,1:10);
  c = zeros(512,512); c0 = 0 ;
  c(17:496,17:496) = b ;
   c0 =1+lpfilter(c,0.001,0.002);% figure(2); imagesc(c0);
   c = (1+c) ./ c0 ;
   c = bpfilter(c,0.05,0.5); 
  figure(1);   imagesc(c);colormap(gray); axis image;
% c = c - median(c(:));
   w1 = hanning(512);
   win =w1*w1'; c = c.*win;
  c = c - mean(c(:));
  c = deci(c,4);
  c = embed(c,4);% figure(4),imagesc(c);
% figure(1);   imagesc(c);
  b = abs(fftshift(fft2(c)));mb = median(b(:));
  b(256-16:256+16,256-16:256+16)=mb;
  figure(2);  imagesc(b);
  a = 0; a = xy2rt(b,257,257,1:255,-pi:0.01:pi);
 
  a = sum(a); b=0;b=0:254;
  a = a.* b;
% a(1:25)=median(a(:));
  figure(3);  plot(a);

  k = peak1d(a);
  
  k = k/4;



