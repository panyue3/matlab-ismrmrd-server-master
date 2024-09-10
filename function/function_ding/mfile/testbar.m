% generate a test img, stripes with a circular modulation.
% a = testbar(k0,N) ; k0 is the wavelength ; n is the output
% dimension N x N pixel. 

function a = testbar(k0,N)

[x4,y4] = meshgrid(1:N);

x4 = x4 /255;

y4 = y4 /255;

c4 = ((exp(-((x4-0.5).^2+(y4-0.5).^2)/0.25)-exp(-1)) > 0);

z2 = (sin((k0*0.7+x4+y4)*2*pi.*x4 + (k0*0.7-y4)*2*pi.*y4));
%+sin(60*pi*x4*(-0.5)+60*pi*y4*(sqrt(3)/2)) +sin(60*pi*x4*(-0.5)+60*pi*y4*(-sqr$

%a = z2.*c4;
a=z2;
img(a)



