function z4 = testhex(k0); 
[x4,y4] = meshgrid(0:511);

x4 = x4 /512 ;
y4 = y4 /512;

c4 = ((exp(-((x4-0.5).^2+(y4-0.5).^2)/0.25)-exp(-1)) > 0);

z2=(sin(2*k0*(1+0.1*x4).*pi.*x4)+sin(k0*2*pi*x4*(-0.5)+k0*2*pi*y4*(sqrt(3)/2)) +sin(k0*2*pi*x4*(-0.5)+k0*2*pi*y4*(-sqrt(3)/2)));

%z4 = z2.*c4; 
z4 = z2;
img(z4)
