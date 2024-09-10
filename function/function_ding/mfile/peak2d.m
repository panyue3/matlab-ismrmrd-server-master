function [x,y] = peak2d(b9);

b9 = b9 - min(b9(:));
b9_x = sum(b9,2);
b9_y = sum(b9,1);

x = peak1d(b9_x);
y = peak1d(b9_y);


