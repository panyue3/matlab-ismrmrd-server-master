% Find the angle between the different k
% [delta,k,k00] = movieang(a,kn); a is the movie, ang is standard angle
% k00 is the primary k of the pattern.
% kn=6 for hexagon,the default size of the movie is 160 X 120
% k is the average k of the movie; delta is the average diff from 2*pi/kn;
% ratio is the power ratio between the sl part and the normal part

function [delta,k,ratio] = movieang(fname, kn,k00)

ang = 360/kn;
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
for j=1:i,
   k=1; 
   b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.06)+0.1); 
   b1(:,:,j)=lpfilter(hpfilter(b1(:,:,j),0.1),0.8);
   a(1:128,1:128,j)=abs(fftshift(fft2(b1(:,:,j))));% a(65,65,j)=0;imagesc(a(:,:,j)), pause(10)
   a1(1:64,1:60,j)=xy2rt(a(:,:,j),65,65,1:60,0:0.099:2*pi);
   a1(:,1:5,j)=1;

%  a11=sum(a1(:,:,j)).*[0:59];size(a11),plot(a11,'o-');pause(10)   
   a11=sum(a1(:,:,j)).*[0:59]; movk(j)=peak1d(a11);
%  imagesc(a1(:,:,j)); pause(10)    
   kprim=sum(sum(a1(:,k00-2:k00+2,j),2),1);
   ksl=sum(sum(a1(:,6:k00-3,j),2),1); 
   ra(j)=ksl/kprim;

   x1=0;y1=0;
   b0=zeros(64,60);a0=0;b0=a1(:,:,j);
   a0 = max(max(max(a1(:,:,j))));
   a01=a0;
   [x,y]=find(b0==a0);
   theta(k,j)=x(1)*0.099;
   b0(:,floor(y(1)*1.3):60)=0;  %/all higher k = 0/%
%   imagesc(b0),y, pause(10)
   while k < 6 ;
      k=k+1;
      low=x(1)-2; high=x(1)+2;
      if x(1)-2<1,low=1;end
      if x(1)+2>64, high=64;end
      b0(low:high,1:floor(y(1)*1.3))=0;% imagesc(b0), pause(5)
      a01 =  max(max(max(b0)));% pause(1)
      [x,y]=find(b0==a01);% pause(1)
      theta(k,j)=x(1)*0.099;
   end
%  imagesc(b0);
%  pause(5)
end

theta = sort(theta);
for m=1:5 delta(m,1:i)=theta(m+1,:)-theta(m,:); end
delta(6,:)=2*pi-(theta(6,:)-theta(1,:));delta=abs(delta-pi/3); 
delta0 = sum(delta,1)/6;delta=0;
delta = mean(delta0(:));
k = 0; k=median(movk(:));
ratio = median(ra);











