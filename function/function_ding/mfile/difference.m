k=sqrt((2*pi*20*(1+0.5*sin(x))*sin(pi/6)).^2+(2*pi*20*(1+0.5.*sin(y))*cos(pi/6)).^2);
%k=sqrt((pi*40*(1+sin(x)/2)*sin(pi/6))^2+(pi*40*(1+sin(y)/2)*cos(pi/6))^2);
%k=sqrt((pi*40*(1+sin(x)/2)*sin(pi/6))^2+(pi*40*(1+0.5*sin(y))*cos(pi/6))^2);
%k = 2*pi*10.*(1+0.1.*y);
k1 = k(2:255,2:255);
figure(4)
img(k1)
colorbar
dif = (kf-k1)./k1;
figure(5)
img(dif)
colorbar
rd = (dif.*dif);
