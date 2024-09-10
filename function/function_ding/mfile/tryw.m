a = testbar(21.5,256);
k0 = roughk(a);
[l1,l2] = size(a);
ang = findang(a,1,k0);
b1 = cos(ang(1))^2; b2 = sin(ang(1))^2;

ed1 =3*floor(l1/k0) + 1,  ed2 = 3*floor(l2/k0) + 1,

% new img file with a wide edge
b(4*ed1+l1,4*ed2+l2) = 0;
for i=1:l1, for j=1:l2, b(2*ed1+i,2*ed2+j)=a(i,j);end,end

% Guassian Window
r0 = sqrt(ed1*ed2);
[y,x]=meshgrid(1:4*ed1+1,1:4*ed2+1);
z =exp(-(1+b2)*(y-2*ed1-1).^2./(2.0*ed1*ed1)-(1+b1)*(x-2*ed2-1).^2./(2.0*ed1*ed1));
%c1 = (sqrt((y-2*ed1-1).^2+(x-2*ed2-1).^2)<=1.2*r0);
%c2 = (sqrt((y-2*ed1-1).^2+(x-2*ed2-1).^2)>1.2*r0);
%z0 = exp(-2*((y-2*ed1-1).^2+(x-2*ed2-1).^2-1.44*r0*r0)/(r0*r0));
%z = c1+z0.*c2;

k = 0;j0=0;
for j = 2*ed2+1:64:2*ed2+l2
j0 =j0+1;i0 = 0;
for i =2*ed1+1:64:l1+2*ed1
   i0 = i0 + 1;  
   c = b(i-2*ed1:i+2*ed1,j-2*ed2:j+2*ed2);    
   c = c.*z;
   r = l1/ (4*ed1+1);
   c = embed(c,r);
   
   [k(i0,j0),sd] = findtotalk(c,k0,0);
% k(i0,j0)=k(i0,j0)/r; sd=sd/r;
%   [l,m] = fit2d(c);

%   [l,m] = find(d == maxa);
%   k(i0,j0) = sqrt((l(1)-2*ed1-1)^2+(m(1)-2*ed2-1)^2);
%   k(i0,j0) = 1/r* sqrt((l(1)-257)^2+(m(1)-257)^2);

end
end
