% function c = moviek(filein,m,n,k); m,n, are the size of the pic
% k is the internal of the two pic you want to do corr

function c1 = moviecorr(filein,m,n,k)

fid=fopen(filein,'r'); i=1;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a+1;
while prod(size(a))==m*n, 
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
b1 = ones(128,128,i);
b1(:,5:124,:)=b(19:146,:,:);
%figure(1), imagesc(b1(:,:,1))
for j=1:i, b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.04,0.02)+1);end
%figure(2), imagesc(b1(:,:,1)),
%figure(4),imagesc(lpfilter(b1(:,:,j),0.04,0.02));
b = b1 ;b1 = 0 ; b1 = ones(64,64,i);
b1(:,:,:)=b(33:96,33:96,:);
i,% figure(3), imagesc(b1(:,:,1))
c = 0;
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
fclose(fid);



