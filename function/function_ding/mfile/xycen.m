% find the center of matrix b9 (center of mass).

function [x,y] = xycen(ff9);
ff9 = double(ff9);

maxff9 = max(ff9(:));
[y,x] = find(ff9 > 0.7*maxff9);

n9 = length(x);
p = 0;
x9 = 0 ; y9 =0;
 for i =1 : n9 ,
   p = p + ff9(y(i),x(i));
   x9 = x9 + x(i)* ff9(y(i),x(i) );
   y9 = y9 + y(i)* ff9(y(i),x(i) );
 end

x = x9 / p ;
y = y9 / p ;

