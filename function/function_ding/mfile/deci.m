function outimg=deci(inimg,sf)
%decimate a matrix


[sy,sx]=size(inimg);
[x,y]=meshgrid(1:sx,1:sy);
xa=1:sf:sx;
ya=1:sf:sy;
[xo,yo]=meshgrid(xa,ya);
outimg=interp2(x,y,inimg,xo,yo,'spline');
