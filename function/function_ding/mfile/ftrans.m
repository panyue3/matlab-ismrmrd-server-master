%  Fourier Transformation of a image
%

function [k] = ftrans(fname); 
  a = imread(fname);
  a = double(a);
  b(1:480,1:480) = a(1:480,65:544);
  c0 = a(:,1:10); 
  c = ones(512,512); c0 = 0 ;    
  c(17:496,17:496) = b ;
  c0 =1+ lpfilter(c,0.001,0.01);
  c = c ./ c0 ;
  c = c - median(c(:));
  figure(1)
  imagesc(c)
  w1 = hanning(512);
  win =w1*w1'; c = c.*win;
  b = abs(fftshift(fft2(c)));
  figure(2)
  imagesc(b);
  a = 0; a = xy2rt(b,257,257,1:255,-pi:0.01:pi);
  figure(3)
  a = sum(a);
  a(1:6)=median(a(:));
  plot(a);
  
  k = peak1d(a);
