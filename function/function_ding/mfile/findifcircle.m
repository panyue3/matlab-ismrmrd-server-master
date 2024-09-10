count = 0;
a=ones(160,120,1);b=ones(160,120,2);b1 = ones(64,64,40);b2=ones(64,64);b3=ones(64,64);
b2f=ones(64,64);b3f=ones(64,64);c0=ones(64,64);
for ang = 0:10:350;
for acc = 220:4:332;
fname = sprintf('%i%i',acc,ang),
fid = fopen(fname,'r');i=1;m=160;n=120;k=1;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
% b1 = ones(64,64,i);
b1(:,:,:)=b(46:109,27:90,:);
for j=1:i,
b1(:,:,j)=hpfilter(b1(:,:,j),0.1);
b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.04)+1);end
fclose(fid);c = 0;
load circle20f2to3.dat
b3=circle20f2to3;,b3 = b3 - mean(b3(:)) ;  b3 = b3/std(b3(:)); 
b2 = sum(b1,3);
b2 = b2-mean(b2(:)); b2=b2/std(b2(:));
count = count + 1;
%ifc(count) = sum(sum(b2.*b3))/64/64;

b2f=fft2(b2);b3f=fft2(b3);c0=(real(ifft2(b2f.*conj(b3f))));ifc(count)=max(c0(:));

end, end;







