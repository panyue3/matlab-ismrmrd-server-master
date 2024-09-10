function fv=dingmin(xo,xa,ya,ia);

xo

fv=sqrt(sum(sum((ia-xo(1)*exp(-((xa-xo(2)).^2)/xo(3)-((ya-xo(4)).^2)/xo(5))).^2)));
