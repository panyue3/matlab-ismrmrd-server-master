% Eiegnvalue distribution of Random Matrix
% p = RM_dist(sigma, beta, x)
% p = p(x): Probability vector
% sigma: Noise variance (median eigenvalue)
% beta: k/N (image #)/(pixe #)
% x: vector of bins


function p = RM_dist(sigma, beta, x)

x_min = sigma*(1-sqrt(beta))^2;
x_max = sigma*(1+sqrt(beta))^2;
dx = mean(diff(x));
x0 = (min(x) - dx):(0.1*dx):(max(x)+dx) ; % grid
p_t = zeros(size(x0)) ; % probability density

%p = zeros(size(x));
t = find( ( x0>x_min ) & ( x0<x_max ) ) ; 
p_t(t) = sqrt( (x0(t)-x_min).*(x_max-x0(t)) ) ./ (2*pi*beta*x0(t))/sigma ;
size(p_t)
t_p = cumsum(p_t)*dx/10; % accumutive sum

p = diff(t_p([1,16:10:end]));
sum(p);