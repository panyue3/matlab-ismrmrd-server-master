% window a image using hanning window.
%

function b = wind(a);

[l,m] = size(a);
u = kaiser(l,5);
v = kaiser(m,5);
c = u*v';
b = a.*c;
