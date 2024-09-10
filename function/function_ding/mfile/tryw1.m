a = testbar(21.5,256);
[l1,l2] = size(a);
 k0 = roughk(a);
ed =2*floor(sqrt(l1*l2/k0/k0)) + 1,

[y,x]=meshgrid(1:l1,1:l2);

k = 0;j0=0;
for j = 2*ed+1:64:2*ed+l2
j0 =j0+1;i0 = 0;
for i =2*ed+1:64:l1+2*ed

   % Guassian Window
   z = exp((-(x-i).^2-(y-j).^2)/(ed*ed));
   b = a.*z;
   ang = findang(b,1,k0);
   b1 = cos(ang(1))^2; b2 = sin(ang(1))^2;
   k0 = roughk(b);
   z = exp((-(0.001+b1)*(x-i).^2-(0.001+b2)*(y-j).^2)/(0.001*ed*ed));
   b = a.*z ;
   i0 = i0 + 1;

   [k(i0,j0),sd] = findtotalk(b,k0,0);

end

end

