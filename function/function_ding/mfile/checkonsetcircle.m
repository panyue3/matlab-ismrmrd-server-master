
function [onset,cir] = checkifcircle(fname)
   
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

x01=1:128;win0=exp(-0.001*(x01-65).^2);win01=win0'*win0;% imagesc(win01),pause(10)
for j=30:39
    c=0;c0=0;ccorr=0;fit=0;
    b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.2)+0.1);
    b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.2),0.8);
    a0=0;% imagesc(b1(:,:,j)), pause(1)
    a0=b1(25:90,30:95,j); 
    if mean(a0(:))~=0, a0 = a0/mean(a0(:)); end
    imgstd(j)=std(a0(:));
    
    b1(:,:,j)=(win01).*b1(:,:,j); % imagesc(b1(:,:,j)), pause(1)
    a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));

    a1=xy2rt(a(:,:,j),65,65,1:60,0:((2*pi)/360):2*pi);a1(:,1:3)=0;
    a1=a1(1:360,:); % figure(2),imagesc(a1(:,:)), pause(1)
    a1(:,1:3)=median(median(a1)); line=sum(a1).*(1:60);
    lmax=max(line(:));
    k00(j) = find(line==lmax(1));    
%    k00(j)=peak1d(line);
%   figure(1),plot(line,'o-'),pause(1)
    if k00(j)<2|k00(j)>58, k00(j)=30;end, %k00(j)
    c9=a1(:,k00(j)-1:k00(j)+1);c=sum(c9,2);
    c=c-mean(c);% figure(1),plot(c), pause(1)
    if (std(c)*hexstd)~=0;
       jnk=xcorr(c,hexref,'biased')/(std(c)*hexstd);
    else
       jnk = 0;
    end
    ct(j)=max(jnk);

end
    cti=find(ct~=0); ct(cti);
   cans=median(ct(cti)); cir=cans;
   ki =find(k00~=0);
   k=k00(ki);
   onset = median(imgstd(30:39));

