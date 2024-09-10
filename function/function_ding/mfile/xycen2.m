% find the center of matrix b9 (center of mass).

function [d] = xycen(ff9);
ff9 = double(ff9);

maxff9 = max(ff9(:));
[y,x] = find(ff9 > 0.85*maxff9);

n9 = length(x)
p = 0;
d=0;
 for i =1 : n9 ,
   p = p + ff9(y(i),x(i));
   x9 = (x(i)-721);
   y9 = (y(i)-721);
   d=d+sqrt((x(i)-721)^2+(y(i)-721)^2)*ff9(y(i),x(i));
 end

d=d/p;

