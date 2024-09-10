%
% k = findtestk(a,k0) a is the image , k0 is the k0 of a .
%  


function k = findtestk(z4,k0); 

pkb=0; inten =0 ; cc =1 ; ratio = 0.9;
decifac = 2 ;
ll = size(z4);
ww = hanning(ll(1));
z4 = z4.*(ww*ww');
z = embed(deci(z4,decifac),decifac); 

b4 = abs(fftshift(fft2(z)));
ffac=1;
b4rt=xy2rt(b4,721,721,1:1/ffac:600,0:0.01:2*pi);
b4sum=sum(b4rt);
plot(b4sum)

pk0 = find(b4sum == max(b4sum));

pk=(pk0-4):(pk0+4);

pf=polyfit(pk,b4sum(pk),3);
pf1 = pf ;
n=length(pf1)-1;
for i=1:n,
  pf1(i)=(n+1-i) *pf1(i);
end

rt = roots(pf1(1:n));

for j = 1:2,
   if rt(j) > (pk0-1) & rt(j) < (pk0+1) ,
      k = rt(j)/(decifac*ffac) ;
      break;
   end
end

k =  k, k0 = k0,

percentageerror = (k-k0)/k0*100
 
 
%b5 = b4(1:size(b4),1:size(b4)/2);

%maxb4 = max(b4(:));
%maxb5 = max(b5(:));

%[x1,y1] = xycen(b4 );

%[x2,y2] = find(b5 == maxb5);
%[x2,y2] = xycen(b5);

%k = (sqrt((x1-x2)^2+(y1-y2)^2))/decifac;

%percentageerror =100* (k-k0)/k0;

%k0
%k
%percentageerror
% (rt(j) > (pk0 - 1)) & (rt(j) < (pk0 + 1));
