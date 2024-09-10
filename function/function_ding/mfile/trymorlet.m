% Generate a morlet wavelet a = trymorlet()

a4 = testbar(21.5,512);
k0 = roughk(a4);
ang = findang(a4,1,k0);
b1 = cos(ang(1)); b2 = sin(ang(1));
[l,m] = size(a4);
[x,y] = meshgrid(1:l);

k = 0; ;n1=0;    
for x0 = 32:64:l-32,
n1 = n1+1; n2=0;
for y0 = 32:64:l-32,
n2 = n2+1;
a = 1 ; d = 1 ;c = 1; de = 1;
% a is the dilation b is the cos()
    r = sqrt((y-y0).^2+(x-x0).^2);

 psik0=exp((2*pi*a*(b1*k0*(x-x0)+b2*k0*(y-y0))/m*1i-a*a*((x-x0).^2*(2-b1*b1)+(y-y0).^2*(2-b2*b2))/1000));
 psik0 = psik0 - sum(psik0(:));
 int0 = abs(sum(sum(a4.*psik0)))

while c ~=0 ;
    a = a+d*0.01/de ;
    c = c + 1 
    psik = exp((2*pi*a*(b1*k0*(x-x0)+b2*k0*(y-y0))/m*1i-a*a*((x-x0).^2*(1.01-b1*b1)+(y-y0).^2*(1.01-b2*b2))/100));
    psik = psik -sum(psik(:));
    int = abs(sum(sum(a4.*psik)));
    if c~=2 & de==10 & int< int0,k(n1,n2)=a*k0; break ; end;
    if c~=2 & int < int0 & de == 1, de = 10;d = d*(-1) ; end;
    if c==2 & int < int0, d = -1;c = 1;end;
    int0 = int;
%   psib=exp((a*b*k*r*i-a*a*r.*r/10)-exp((a*b*k*r*i-a*a*r.*r/10); 
%   int =     
%
    
end;    
end;
end;
