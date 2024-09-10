% check if it is SL  
% k00 is the primary k  
% ratio is a 1-d vector, size is the # of images =12;  
 
function ratio = checkmovsl(fname,k00)

fid = fopen(fname,'r');
i=1;m=160;n=120;x=0;y=0;
a=fread(fid,[m,n],'uchar');
b=zeros(m,n,2);b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
fclose(fid);

b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);

for j=1:i
   b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.06)+0.1);
   b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.1),0.8);
   a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));
   a1(1:64,1:60,j)=xy2rt(a(:,:,j),65,65,1:60,0:0.099:2*pi);
   a1(:,1:5,j)=1;
end
   ratio(1:12) = sum(sum(a1(:,1:k00-3,:)))./sum((sum(a1(:,k00-2:k00+2,:))));    
 
