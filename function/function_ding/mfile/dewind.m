% dewindow a image using a kaiser window

function b = dewind(a);

[l,m] = size(a);
u = kaiser(l,5);
v = kaiser(m,5);
c = u*v';
b = a./c;


