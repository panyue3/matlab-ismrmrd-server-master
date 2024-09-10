% function [z] = fitgaussian1D(p,v);
% v: fitting function v = v(x)
% x: variable x-axis 
% p(1): center; p(2): width; p(3): amp

function [z] = fitgaussian1D(p,v);

%cx = p(1);
%wx = p(2);
%amp = p(3);
%if prod(size(v)-size(x)), v = v';end
x = 1:length(v);
zx = p(3)*exp(-0.5*(x-p(1)).^2./(p(2)^2)) - v;
z = zx;
%z = sum(zx.^2);

