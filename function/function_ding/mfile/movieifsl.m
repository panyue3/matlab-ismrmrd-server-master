% Check if the movie is made of Super Lattice
% Find the length scale smaller than wave length
% function delta = movieifsl(fname,k) k is the wave length

function delta = movieifsl(fname,k0)

fid = fopen(fname,'r');
i=1;m=160;n=120;x=0;y=0;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
fclose(fid);
a=0;a1=0;theta=zeros(6,i);buf=zeros(160,120);
b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);
blp = lpfilter(b1(:,:,1),0.1);
for j=1:i
   m=1;
   b1(:,:,j)=b1(:,:,j)./(blp+0.1);buf = b1(:,:,j);
   b1(:,:,j)=hpfilter(lpfilter(buf,0.8),0.15);
   buf = zeros(160,120);
   a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));
   a1(1:64,1:60,j)=xy2rt(a(:,:,j),65,65,1:60,0:0.099:2*pi);
   a1(:,1:5,j)=0; a1(:,k0-1:60)=0;	
   b0 = zeros(64,60) ; b0 = a1(:,:,j) ;
   [x,y]=find(b0 == max(max(b0)));
   theta(m,j)=x*0.099;
   while m < 6 ;
      m = m + 1 ;
      low = x - 2; high = x + 2;
      if x-2<1,low=1;end
      if x+2>64, high=64;end
      b0(low:high,1:floor(y*1.3))=0;
      a01 =  max(max(max(b0)));
      [x,y]=find(b0==a01);
      theta(m,j)=x(1)*0.099;
    end
end

   theta = sort(theta);
   for m=1:5 delta(m,1:i)=theta(m+1,:)-theta(m,:); end
   delta(6,:)=2*pi-(theta(6,:)-theta(1,:)); 

