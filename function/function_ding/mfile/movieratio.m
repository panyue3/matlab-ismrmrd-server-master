% find the power ratio between the power in side k0 and outside k0.
% k00 is the rough k.

function ratio = movieratio(fname,k00);
fid = fopen(fname,'r');
i=1;m=160;n=120;x=0;y=0;
a=fread(fid,[m,n],'uchar');
b=zeros(m,n,2);b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
fclose(fid);
a=0;theta=zeros(6,i);
b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);b10=zeros(128,128);
[xm,ym]=meshgrid(1:128,1:128);
mask1=(sqrt((xm-65).^2+(ym-65).^2)<k00-2);mask2=1-mask1;
mask3=(sqrt((xm-65).^2+(ym-65).^2)>4);
for j=1:i
%  j  
   b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.06)+0.1);
   b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.1),0.8);
   a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j)))).*mask3;
%  imagesc(a(:,:,j));pause(5)
   ra(j)=sum(sum(a(:,:,j).*mask1))/sum(sum(a(:,:,j).*mask2));
end
   ratio=median(ra);
%figure(1),imagesc(a(:,:,40)),colorbar
%figure(2),imagesc(mask2),colorbar
