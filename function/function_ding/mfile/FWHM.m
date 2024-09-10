% function [r, r_max] = FWHM(a)
% Find the FWHM of the autocorrelation function of image a.
% First take a = my_corr2(a,a), then find the FWHM

function [r, r_max] = FWHM(a)

a = my_corr2(a,a);
s = size(a);
a_m = max(a(:));
x_c = round((s(2)+1)/2); % Center point
y_c = round((s(1)+1)/2); % Center point

x_d = round(x_c/2); % x-coordinate width
y_d = round(y_c/2); % y-coordinate width
[x_0,y_0] = meshgrid(x_c-x_d:x_c+x_d, y_c-y_d:y_c+y_d);
[x_I,y_I] = meshgrid(x_c-x_d:0.5:x_c+x_d, y_c-y_d:0.5:y_c+y_d);

a_0 = interp2( x_0,y_0, a(y_c-y_d:y_c+y_d, x_c-x_d:x_c+x_d),x_I,y_I,  'spline');
s0 = size(a_0);
% figure(1), imagesc(a), figure(2),imagesc(a_0),figure(3)
[x,y] = contour(1:s0(2),1:s0(1),a_0,[a_m/2 a_m/2]);%, axis image, pause
close all,
x_c = round((s0(2)+1)/2); % Center point
y_c = round((s0(1)+1)/2); % Center point

r = 2*sqrt(polyarea(x(1,2:end),x(2,2:end))/pi) / 2;% FW -> 2*; interp2 by 2 -> /2.

r_max = 2*max(sqrt( ( x(1,2:end) - x_c ).^2 + ( x(2,2:end) - y_c ).^2 )) / 2;

%sqrt( ( x(1,2:end) - x_c ).^2 + ( x(2,2:end) - y_c ).^2 )
%x_c,y_c