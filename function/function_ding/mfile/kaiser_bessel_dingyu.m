
% kaiser-bessel function for regridding
% kb = kaiser_bessel(w, b)
% w: width
% b: beta
% kb: kaiser-bessel function kernel, length:100*(w+2)+1
% step size: 0.01

function [kb, kb_grid] = kaiser_bessel_dingyu(w, b,varargin)

if nargin == 3
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





