% [imout]=xy2rt(imin,cx,cy,nr,nt)

function [imout]=xy2rt(imin,cx,cy,nr,nt)

[sx sy]=size(imin);
[xi yi]=meshgrid(1:sy,1:sx);

[r th]=meshgrid(nr,nt);

xo=cx+r.*cos(th);
yo=cy+r.*sin(th);

imout=interp2(xi,yi,imin,xo,yo,'cubic');
