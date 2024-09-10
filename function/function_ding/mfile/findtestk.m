% k = findtestk(a,meth) a is the image, First apply a window, then deci
% and imbedding.
%  meth is the method of fitting. 0 is Gaussian, 1 is Polyfit;

function k = findtestk(z4,meth); 

n= 0; m = 0;
z4 = double(z4);
z4 = z4 -mean(z4(:));
ll = size(z4);
ww = hanning(ll(1));
z4 = z4.*(ww*ww');

% find roughly what k is:
pk9 = roughk(z4);

[x0,y0]=size(z4);  
cx0=floor(x0/2)+1
cy0=floor(y0/2)+1;

cr = (cx0-16) / pk9;  
while cr > 3  
   m = m +1 ;
   cr = floor(((cx0-5) / (pk9 *(2^m)))); 
   if m > 2,
      'Warning 1 : Something is wrong, decifactor is too large!!!'
    end
end

decifac = 2^m; 
emfac =2* decifac ;
z = embed(deci(z4,decifac),emfac); 
%figure(5)
%img(z)
b4 = abs(fftshift(fft2(z)));

[x,y]=size(z);
cx=floor(x/2)+1;
cy=floor(y/2)+1;

b4rt=xy2rt(b4,cx,cy,1:cx,-pi:0.05:pi);
b4sum=sum(b4rt);

if meth == 0
   b4sum = log(b4sum);
   pk9 = find(b4sum == max(b4sum));
   pk=(pk9-2):(pk9+2);
   pf1=polyfit(pk,b4sum(pk),2);
   k = (-1)*(pf1(2)/(2*pf1(1)))/(emfac);
else
pk9 = find(b4sum == max(b4sum));
pk=(pk9-2):(pk9+2);

pf1=polyfit(pk,b4sum(pk),3);
n=length(pf1)-1;
for i=1:n,
  pf1(i)=(n+1-i) *pf1(i);
end

rt = roots(pf1(1:n));

j = 0 ;
for j = 1:2,
   if rt(j) > (pk9-1) & rt(j) < (pk9+1) ,
      k = rt(j)/(emfac) ;
      break;
   end
end
end

k=k 
%k0=k0
%percentageerror = (k-k0)/k0*100
