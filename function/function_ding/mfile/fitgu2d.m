% function [cx,cy] = fit2d(z4)
%

function [cx,cy] = fitgu2d(a);

ll = size(z4);
maxa = max(a(:));
meana = mean(a(:));
[y1,x1] = find(a == maxa);

btest = a(y1(1)-2:y1(1)+2,x1(1)-2:x1(1)+2);
[xa,ya] = meshgrid(-2:2,-2:2);


