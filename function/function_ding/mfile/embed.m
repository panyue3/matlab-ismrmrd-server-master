%  function outimg=embed(inimg,sf); sf is the ratio;
%

function outimg=embed(inimg,sf)

%inimg=inimg-mean(inimg(:));
[x1,y1]=size(inimg);
x = round(x1/2); y = round(y1/2);
xo=round(sf*x1);
yo=round(sf*y1);
outimg=zeros(xo,yo);
outimg(xo/2-x:xo/2+x1-x-1,yo/2-y:yo/2+y1-y-1)=inimg;
