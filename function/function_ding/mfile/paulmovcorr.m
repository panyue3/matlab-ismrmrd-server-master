function corr = moviek(filein,m,n)

clear b;
fclose('all');
fid=fopen(filein,'r'); 
i=1;
a=fread(fid,[m,n],'uchar');
b(:,:,1)=a;
while prod(size(a))==m*n,
  a=fread(fid,[m,n],'uchar');
  if prod(size(a))==m*n,
     i=i+1;
     b(:,:,i)=a;
  end
end
fclose(fid);
bn=zeros(111,111,i);
size(bn)
size(b)

for j=1:i,
 bn(:,:,j)=b(28:138,5:115,j);
 bn(:,:,j)=bn(:,:,j)-mean(reshape(bn(:,:,j),111*111,1));
 stda(j)=std(reshape(bn(:,:,j),111*111,1));
end
clear b

len=floor(i/2);
len=20;
corr=zeros(len+1,1);
for dlt=0:len,
  dlt
  temp=0;
  for j=1:(i-dlt),
    j
    a1=reshape(bn(:,:,j),111,111);
    a1=hpfilter(a1,0.05,0.06);
    a1f=(fft2(a1));
%    a2f=(fft2(reshape(bn(:,:,j+dlt),111,111)));
    a2f=a1f;
%    img(reshape(bn(:,:,j),111,111));
    c=fftshift(real(ifft2(a1f.*conj(a2f))));
    bad=find(isnan(c));
    c(bad)=0;
    img(c);
    colorbar;
    pause(10);
    d=xy2rt(c-mean(c(:)),56,56,0:50,0:0.01:(2*pi));
    imagesc(d);
    pause(10);
    plot(abs(sum(d).*(1:51)))
%    plot(sum(d));
    pause(10);
    mc=max(c(:))
    temp=temp+mc/(stda(j)*stda(j+dlt));
  end
  corr(dlt+1)=temp;
  plot(corr/corr(1),'bo-');
  pause(1);
end
corr=corr/corr(1);
