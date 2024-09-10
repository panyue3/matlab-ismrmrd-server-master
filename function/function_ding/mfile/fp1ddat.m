function [f, g, ph]=fp1d(nm)

 all clear;


name=sprintf('/usr/home/lab/shared/ding/data/April02/041802/%s.dat',nm);
 a=load(name);
 back = load('/usr/home/lab/shared/ding/data/April02/041802/000.dat');
 a = (a+0.00013)./ (back+0.00013) ;
% me = mean(back(:))
 figure(1);
 b=double(a(5:255,30:285));
 imagesc(b);
 c=(xy2rt(b,129,131,1:2:150,0:0.01:2*pi));
 d=(c(:,54:59));
 figure(2);
 image(c);
 size(c)
 e=sum(d');
 f=e-mean(e(:));
 figure(3);
 plot(f);
 g=fft(f);
 figure(4);
 plot(0:max(size(f))-1,abs(g));
 ph=atan2(imag(g),real(g));
% plot(0:max(size(f))-1,atan2(imag(g),real(g)))


