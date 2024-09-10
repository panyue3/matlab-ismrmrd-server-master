% make a target shape test iamge

function a = target(k0);

[x,y]=meshgrid(-128:127,-128:127);
x=x/256;y=y/256;
a = sin(2*pi*k0*sqrt(x.*x+y.*y));
figure(1)
img(a)
