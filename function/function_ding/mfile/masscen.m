% To get the center of mass of an image, usually for a binary image.
% [y0, x0] = masscen(a_0);
% Column, Row

function [y0, x0] = masscen(a_0);

s = size(a_0);
[x, y] = meshgrid(1:s(2), 1:s(1)); % size(a_0), size(x), size(y)

x0 = sum(sum( a_0.*x ))/sum(a_0(:));
y0 = sum(sum( a_0.*y ))/sum(a_0(:));



