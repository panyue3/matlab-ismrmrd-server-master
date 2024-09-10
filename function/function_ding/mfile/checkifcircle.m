
function cir = checkifcircle(fname)

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
ct=0;k00=0;
hexref=zeros(1,360);
for i=1:60:360
  hexref(i)=1;
end
hexref=hexref-mean(hexref);
hexstd=std(hexref);

for j=30:39
    c=0;c0=0;ccorr=0;fit=0;
    b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.1)+0.1);
%   figure(1); imagesc(b1(:,:,j)); pause(2)
    b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.1),0.8);
    b1(:,:,j)=(hanning(128)*hanning(128)').*b1(:,:,j);% figure(1),imagesc(b1(:,:,j))
    a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));


    a1=xy2rt(a(:,:,j),65,65,1:60,0:((2*pi)/360):2*pi);
    a1=a1(1:360,:); %figure(2),imagesc(a1(:,:,j))
    a1(:,1:3)=median(median(a1));
    k00(j)=peak1d(sum(a1).*(1:60));%figure(1),plot(sum(a1).*(1:60)) 
    c=a1(:,round(k00(j)));cmean=mean(c); 
    c=c-mean(c); 
    jnk=xcorr(c,hexref,'biased')/(std(c)*hexstd);
    ct(j)=max(jnk);
%   figure(3); plot(jnk)
%   figure(2); plot(c);
end

    cti=find(ct~=0);
%   ct(cti)
   cans=mean(ct(cti)); cir=cans;  

   ki =find(k00~=0);
   k=k00(ki);     
%  mean(k)
