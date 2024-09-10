% function c = moviek(filein,m,n,k); m,n, are the size of the pic
% k is the internal of the two pic you want to do corr

fid = fopen('a','r');i=1;m=160;n=120;k=1;
%fid=fopen('F:\ding\data\buffer\001.dat','r'); i=1;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n, 
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
b1 = ones(64,64,i);
b1(:,:,:)=b(46:109,27:90,:);
for j=1:i,
b1(:,:,j)=hpfilter(b1(:,:,j),0.1);
b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.04)+1);end
fclose(fid);c = 0;
for j=1:i-k,
   
a1 = b1(:,:,j);   a1 = a1-mean(a1(:)); 
a2 = b1(:,:,j+k); a2 = a2-mean(a2(:));
std1=std(a1(:));
std2=std(a2(:));
    a1f = fft2(a1); a2f = fft2(a2);
    c0 = (real(ifft2(a1f.*conj(a2f))));
    c1(j) =  max(c0(:)/(std1*std2*64*64));
end

   c = sum(c1) / (i-k);
   stdc = std(c1),
   medianc = median(c1), meanc = mean(c1),
   figure(1),
   hist(c1),
   c0 = medianc;

if c0>0.6;

load circle23f2to3.dat;
b3=circle23f2to3; b3 = b3/std(b3(:));
b2 = sum(b1,3); 
b2 = b2-mean(b2(:)); b2=b2/std(b2(:));
ifc = sum(sum(b2.*b3))/64/64;
end

