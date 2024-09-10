% x = 2ffit(a); a is a matrix. Find the first peak and fit it with a 2-D 
% 2nd order polynomial which is : x(1)*x^2 + x(2)*y^2 + x(3)*x*y + x(4)*x +
% x(5)*y + x(6)  

function [cx,cy] = fit2d(z4);

ll = size(z4);
a = z4;
maxa = max(a(:));
meana = mean(a(:));
[y1,x1] = find(a == maxa);

btest = a(y1(1)-2:y1(1)+2,x1(1)-2:x1(1)+2);
[xa,ya] = meshgrid(-2:2,-2:2);

x0 =1 ;
x0(6) = a(y1(1),x1(1));
x0(5) = (x0(6)-a(y1(1)-2,x1(1)-2))/2 ;
x0(4) = x0(5);
x0(2) =  2 * (a(y1(1)-1,x1(1)-1) - a(x1(1),y1(1)) );
x0(1) = x0(2);
x0(3) = 0 ;

options = optimset('TolX',meana*1e-10);
x = fminsearch('dingpolymin',x0,options,xa,ya,btest);

cx = (-2*x(4)*x(2) + x(3)*x(5)) / (4*x(1)*x(2)-x(3)*x(3)) + x1;
cy = (-2*x(1)*x(5) + x(3)*x(4)) / (4*x(1)*x(2)-x(3)*x(3)) + y1;

