
fid = fopen('2900','r');i=1;m=160;n=120;
a = fread(fid,[160,120],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
i,
size(b),
b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);
%figure(1), imagesc(b1(:,:,1))
for j=1:i, b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.04,0.02)+1);end
b = b1 ;b1 = 0 ; b1 = ones(64,64,i);
b1(:,:,:)=b(33:96,33:96,:);
for j=1:i, b1(:,:,j)=b1(:,:,j)-mean(mean(b1(:,:,j)));end
c1=0;
for j=1:i, c1=abs(fftshift(fft2(b1(:,:,j))))+c1;end
c1=c1/i;
figure(1)
img(c1);
c2 = xy2rt(c1,33,33,1:30,0:0.1:2*pi);
figure(2)
c3 = sum(c2).*(1:30);
plot(c3)
fclose(fid);
%clear all
