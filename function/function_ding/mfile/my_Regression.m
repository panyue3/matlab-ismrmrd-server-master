% function [c, R2] = my_Regression( x, y )
% y = c(1)*x + c(2); R2 = 1 - ESS/TSS

function [c, R2] = my_Regression( x, y )

s_x = size(x);
s_y = size(y);

if ndims(x) ~=2 | ndims(y) ~=2 % if it is not 2-D
    c = 0; R2 = 0;
    return
elseif prod( size(x) ) ~= length(x) | prod( size(y) ) ~= length(y) % if it is not 1-D
    c = 0; R2 = 0;
    return
end

if s_x(1) == 1;
    x = x';
end
if s_y(1) ==1;
    y = y';
end

V = [ x, ones(size(x)) ]; % Cutoff_FWHM is the number of the noise mode
size(V);
size(y);
c = V \ y; % same as c = (V' * V) \ (V' * y)

ESS = sum( (sort(y)-( c(1)*sort(x) + c(2))).^2);
TSS = sum( (y - mean( x )).^2 );
R2 = 1 - ESS/TSS ;

