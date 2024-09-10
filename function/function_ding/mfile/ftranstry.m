function [k] = ftrans(fname);
  a = imread(fname);
  a = double(a);
% figure(2); imagesc(a);colormap(gray);
  b(1:480,1:480) = a(1:480,65:544);
%  c0 = a(:,1:10);
  c = zeros(512,512); c0 = 0 ;
  c(17:496,17:496) = b ;% c = c-mean(c(:));
  figure(1);  imagesc(c);
  figure(2); b=abs(fftshift(fft2(c)));b(254:260,254:260)=0;imagesc(b);
  c0 =1+lpfilter(c,0.001,0.05);
  c = (1+c) ./ c0 ;  c = c-mean(c(:));
  figure(3); imagesc(c); b=0;
  figure(4); b=abs(fftshift(fft2(c)));b(254:260,254:260)=0;imagesc(b);
  c = bpfilter(c,0.05,0.5); 
  figure(5);   imagesc(c);

