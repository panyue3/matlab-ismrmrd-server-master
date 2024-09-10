% Generate a morlet wavelet a = trymorlet()

function a = trymorlet(k0,a,N);

[x,y] = meshgrid(1:N);
a = exp(k0(a*x*x + y*y));



