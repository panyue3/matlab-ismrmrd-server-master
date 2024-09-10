% Target function to minimize b = tarfun(c,a,k,thi,phi), c is the image
% a is the amplitude, k is the wave vector, phi is the phase

%   function  b = tarfun(c,a,k,thi,phi);
  function  b = tarfun(x,c);
   a = x(1); k=x(2); thi=x(3); phi=(4);
   z = 1;
   [l,m] = size(c);
   [x,y] = meshgrid(l,m);
%  z = exp(-0.5*((x-(l+1)/2).^2+(y-(m+1)/2).^2)/((l+1)^2+(m+1)^2));
   
   x = x/(l+1); y = y/(m+1);
   fit = a*sin(2*pi*(k*cos(thi)*x+k*sin(thi)*y)+phi);
   b = sum(sum(((c-fit).*z).^2));


