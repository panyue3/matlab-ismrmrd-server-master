

function P = lennard_Jones(V, r, x0, y0, x, y)
% x: meshgrid x
% y: meshgrid y
% V: ratio
%x0 = x0 + 10^(-5)*randn; y0 = y0 + 10^(-5)*randn;
x0 = x0 ; y0 = y0 ;
R = sqrt((x-x0).^2 + (y-y0).^2);
P = V*( (r./R).^12 - (r./R).^6 );
return
