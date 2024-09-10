
% convolution + kaiser-bessel function for regridding
% kb = conv_kb(conv_func, w, b)
% conv_func: convolution function
% w: width
% b: beta
% kb: kaiser-bessel function kernel, length:100*(w+2)+1
% step size: 0.01

function [kb, kb_grid] = conv_kb(conv_func, w, b,varargin)


if nargin == 4
    L = -w/2:(0.01/varargin{1}):w/2;
    kb = besseli(0,b*sqrt(1-(2*L/w).^2))/besseli(0,b);
    kb_grid = kb(1:round(100*varargin{1}):end);
    kb = [zeros(1, round(100*varargin{1})), kb, zeros(1, round(100*varargin{1}))];
else
    L = -w/2:0.01:w/2;
    kb = besseli(0,b*sqrt(1-(2*L/w).^2))/besseli(0,b);
    kb_grid = kb(1:100:end);
    kb = [zeros(1, 100), kb, zeros(1, 100)];
end

% added 2016-09-01, convolution with 
s_c = size(conv_func);
s_center = (s_c+1)/2;

kb_0 = kb'*kb; %figure(10), imagesc(kb_0), axis image, colorbar
kb = zeros(size(kb_0));
conv_func_1 = conv_func;
% conv_func_1 = conv_func(end:-1:1, end:-1:1); % Ding 20160906 Fix a bug
for i = 1:s_c(1)
    for j=1:s_c(2)
        kb = kb + circshift(kb_0, [100*(i-s_center(1)), 100*(j-s_center(2))])*conv_func_1(i, j);
    end
end






