function onset = checkifonset(fname)

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
b1(:,5:124,:)=b(19:146,:,:);

for j=1:40;
    b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.1)+0.1);
    b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.1),0.8);
    a0=0;
    a0=b1(25:90,30:95,j);
    if mean(a0(:))~=0, a0 = a0/mean(a0(:)); end
    imgstd(j)=std(a0(:));
end
%    imagesc(a0)
onset = median(imgstd);     

