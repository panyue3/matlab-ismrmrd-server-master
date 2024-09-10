%  b = blur(a,k0,c,d), a is the k distribution matrix, c,d is the
%  coordinate of the points need to be get rid of. 

function b = blur(a,k0,c,d);

[l,m] = size(a);
r0 = floor(l/k0);
if mod( floor(r0),2 ) ==1,  r=(r0-1)/2; else r=r0/2 ;end;

[x,y] = meshgrid(-r:r,-r:r);
z0 = exp(-(x.*x+y.*y).^2/(r*r));
z1 = (sum(z0(:))-1);
n = length(c);

for i = 1: n,
   if c(i) > r & c(i) < (l-r) & d(i) > r & d(i) < (l-r),
      t = a(c(i)-r:c(i)+r,d(i)-r:d(i)+r).*z0;
      a(c(i),d(i)) = (sum(t(:))-a(c(i),d(i)))/z1; 
   end;
end;

b = a ;
