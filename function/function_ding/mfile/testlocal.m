x = 1:16;
x =x/16; y =y/16;
a = sin(x);
ax = diff(a,1)*16;
axx = diff(ax,1)*16;
