% Cumulative Eiegnvalue Distribution Function of Random Matrix Theory
% p = RMT_CDF(sigma, beta, x)
% p = p(x): Probability
% sigma: Noise variance (median eigenvalue)
% beta: k/N (image #)/(pixe #)


function p = RMT_CDF(sigma, beta, x)

s = size(x);
if ndims(x) > 2 % x is not a vector
    p = 0;
    'ERROR: x is a matrix !'
    return
elseif ( (s(1) > 1) & (s(2) > 1) ) % x is not a vector
    p = 0;
    'ERROR: x is a matrix !'
    return
end
if s(1) > s(2), x = x' ; end % Make sure x is row vector

x_min = sigma*(1-sqrt(beta))^2;
x_max = sigma*(1+sqrt(beta))^2;

% t = ones(10000, 1)*(x-x_min); % 10,000 steps in CDF calculations
% x_t = [0.00005 : 0.0001 : 0.99995 ]'*ones(1, length(x) ) ;
% x_t = x_t.* t + ones(size(x_t))*x_min ; imagesc(x_t), colorbar
% t = 0;

p = zeros(size(x));
p(find(x < x_min)) = 0;
p(find(x > x_max)) = 1;
t = find( (x > x_min) & (x < x_max) ); % The only cases that I have to calculate
x_t = x_min + abs( x_max-x_min )/20000 : abs( x_max-x_min )/10000 : x_max ; 

% for i=1:length(t)
%     temp = abs( x_t - x(t(i)) ) ;
%     t_1 = find( temp == min(temp) );
%     t_t(i) = t_1(1); % t_1 can be a vector
% end
t_t = round( (x(t) - x_min)/( x_max-x_min )*10000 +0.5 ); % find the corresponding positions add 0.5 to avoid 0.

t_t(find(t_t > 10000)) = 10000; % Avoid the t_t > 10000

p_0 = cumsum(sqrt( ( x_t - x_min).*(x_max - x_t ) ) ./ ( 2*pi*beta*x_t )/sigma) * abs( x_max-x_min )/10000;

p(t) = p_0(t_t);
while min(diff(p))<0 % get rid of non-monotunic increase CDF values
    d_diff = find(diff(p)<0) ; 
    for i = length(d_diff):-1:1 % if one is larger than next one
        p(d_diff(i)) =  p(d_diff(i) + 1) ;
    end
end

% for i=1:length(t)
%     if x(i) > (x_max - (x_max - x_min)/20000)
%         p(i) = 1;
%     else
%         x_t = x_min + abs( x(i)-x_min )/20000 : abs( x(i)-x_min )/10000 : x(i) ; 
%         p_t = sqrt( ( x_t - x_min).*(x_max - x_t ) ) ./ ( 2*pi*beta*x_t )/sigma ;
%         x_t = 0;
%         p(i) = sum(p_t)*( x(i)-x_min )/10000;
%     end
% end



