function [f, g, ph]=fp1draw(nm)

close all;


name=sprintf('/usr/home/lab/shared/ding/data/May02/050702/%s.dat',nm);
fid = fopen(name,'r');
 a=fread(fid,[320,266],'uint8');
fclose(fid);
fid =fopen('/usr/home/lab/shared/ding/data/May02/050702/000.dat','r');
 back=fread(fid,[320,266],'uint8');
fclose(fid);
a=a./back-1;
bad=find(a==inf);
a(bad)=0;
a=a';
% me = mean(back(:))
 figure(1);
 b=double(a(10:260,30:285));
 imagesc(b);
 c=(xy2rt(b,128,125,1:2:150,0:0.01:2*pi));
 figure(2);
 imagesc(c)
 d=(c(:,53:60));
 figure(3);
 imagesc(d);
 size(c)
 e=sum(d');
 f=e-mean(e(:));
% figure(4);
 plot(f);
 g=fft(f);
 figure(4);
 plot(0:max(size(f))-1,abs(g));
 ph=atan2(imag(g),real(g));
% plot(0:max(size(f))-1,atan2(imag(g),real(g)))


