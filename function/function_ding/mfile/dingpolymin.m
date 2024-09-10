function fv=dingpolymin(xo,xa,ya,ia);

%xo

fval=xo(1)*xa.^2+xo(2)*ya.^2+xo(3)*ya.*xa+xo(4)*xa+xo(5)*ya+xo(6);

%for i=1:3,
%  for j=1:i,
%    fval=val+xa.^(i-1)*xo(i)+ya.^(i-1)*xo();
%  end
%end

fv=sqrt(sum(sum((ia-fval).^2)));
