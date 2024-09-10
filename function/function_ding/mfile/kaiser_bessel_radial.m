
% kaiser-bessel function in the radial direction for regridding
% kb = kaiser_bessel_radial(w, alpha, stepsize)
% w:        width
% alpha:    over-sampling ratio
% kb:       square shape kaiser-bessel function kernel, with each side:100*(w)+1
% step size: 0.01
% Yu Ding 2017-06-27

function [kb, stepsize] = kaiser_bessel_radial(w, alpha, stepsize)

% w = 6;
% alpha = 1.5
if nargin == 1
    alpha = 1.5;
    stepsize = 0.01;
elseif nargin == 2
    stepsize = 0.01;
end

b = pi*sqrt(w^2/alpha^2*(alpha-0.5)-0.8);
% disp(['Kaiser-Bessel Kernel beta = ', num2str(b)])

N_0 = floor(w/2/stepsize);
% L = -w/2:stepsize:w/2;
L = (-N_0:N_0)*stepsize;

[x_0, y_0] = meshgrid( L, L );
r_0 = sqrt(x_0.^2+ y_0.^2);
kb = zeros(size(r_0));

kb(r_0<w/2) = besseli(0,b*sqrt(1-(2*r_0(r_0<w/2)/w).^2))/besseli(0,b);


