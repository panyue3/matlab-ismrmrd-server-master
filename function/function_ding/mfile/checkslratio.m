% Check if the movie has Super Lattice pattern
% Find the length scale smaller than wave length
% function delta = movieifsl(fname,k0,k1) k0<k1;

function ratio = checkslratio(fname,k0,k1)

fid = fopen(fname,'r');
i=1;m=160;n=120;x=0;y=0;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
fclose(fid);
a=0;a1=0;b0 = 0;m0=0;theta=zeros(6,i);buf=zeros(160,120);
b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);
blp = lpfilter(b1(:,:,1),0.1);
for j=1:i
   
   b1(:,:,j)=b1(:,:,j)./(blp+0.1);buf = b1(:,:,j);
   b1(:,:,j)=hpfilter(lpfilter(buf,0.8),0.1);
   buf = zeros(160,120);
   a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));
   a1(1:64,1:60,j)=xy2rt(a(:,:,j),65,65,1:60,0:0.099:2*pi);
   b0=zeros(160,120);b0 = a1(:,:,j);
   b0=b0-median(b0(:))+1;
   b0(:,1:5)=1; 
   ra(j)=sum(sum(b0(:,6:k0)))/sum(sum(b0(:,k0+1:k1)));
end
%  imagesc(b0)
   ratio = sum(ra)/i;
