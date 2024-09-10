%  data = intenang(filein), output is a 2-D matrix    
%  data(:,i) is the intensity distribution at # i frame.

function [data,ipeak,ival] = intenang(filein)

i=1; N=128;
fid=fopen(filein,'r');
a=fread(fid,[640,480],'uchar');
while prod(size(a))==640*480,
   a=a(192:447,112:367);
   b=lpfilter(a,0.05,.06);
   a=a./b;
%   a=lpfilter(a,0.25,.26);
%   a=hpfilter(a,0.05,.06);
   b=abs(fftshift(fft2(a))); b(129,129)=0;
   b = b -mean(b(:));
   brt=xy2rt(b,129,129,5:25,0:(2*pi/(360)):(2*pi));
   data(i,:)=sum(brt');
   a=fread(fid,[640,480],'uchar');
   i=i+1
end


for j=3:i-1,
  [ival(j-2),ipeak(j-2)]=max(xcorr(data(2,:)-mean(data(2,:)),data(j,:)-mean(data(j,:))));
end








