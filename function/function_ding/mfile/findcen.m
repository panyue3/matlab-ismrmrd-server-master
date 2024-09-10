% [x,y,rf] = findcen(a); [x,y] is the off center displacement, rf is the
% radius.

function [x,y,rf] = findcen(a);

a = double(a);
[sy,sx] = size(a);

[y1,x1] = meshgrid(-sx/2:sx/2-1,-sy/2:sy/2-1);
z = sqrt(x1.^2 + y1.^2);

atc=conj(fft2(a));
width=14;
ya=zeros(1:10);
xa=ya;
oldmax=0;
for i = 1 : 10
    c1 = 0; c2 = 0 ; c0 = 0 ; cc = 0 ;
    radius(i)=269-1*i;
    c1 = ( z < (radius(i)) );
    c2 = ( z > (radius(i)-width) );
    c0 = 1-c1.*c2;
    cc = fftshift(real(ifft2(atc.*(fft2(c0)))));
    maxcc(i) = max(cc(:));
    if (max(maxcc)>oldmax),
      oldmax=max(maxcc);
      tmp=cc;
      tmpcirc=c0;
    end
    [ya(i),xa(i)]=find(cc==maxcc(i));
end

p=polyfit(radius,maxcc,3);
%figure
%plot(radius,maxcc)
if p(1) < 0,
  rf=(-2*p(2)-sqrt(4*p(2)^2-12*p(1)*p(3)))/(6*p(1));
else
  rf=(-2*p(2)+sqrt(4*p(2)^2-12*p(1)*p(3)))/(6*p(1));
end
 
if imag(rf)==0,
else
'Warning! Image center is wrong!'
end

rf=rf-width;

%figure;
%colormap(hot);
%img(tmp);

maxc0 = max(maxcc);
w = find(maxcc==maxc0);
x=(sx+1)/2-xa(w);
y=(sy+1)/2-ya(w);
r=radius(w) - width;
[y1,x1] = meshgrid((-sx/2-x):(sx/2-1-x),(-sy/2-y):(sy/2-1-y));
z = sqrt(x1.^2 + y1.^2);
c1 = ( z < (radius(w)) );
c2 = ( z > (radius(w)-width) );
c0 = 1-c1.*c2;
%figure;
%colormap(hot);
%img(double(a).*c0);

