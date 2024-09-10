% function [a_r, V, D] = KLT_Filter2D(a, r), filter 2-D instead of 3-D
% data.
% r: ratio of keeping eigenimages, value between 0 and 1, 

function [a_r, V, D] = KLT_Filter2D(a, r)

s = size(a);
N = min(s);
if length(s) ~=2,
    'Error: Input array is not a 2-D array!'
    a_r = a;
    return
end

if r>1|r<=0
    'Error: The ratio r must with the range of (0 1]'
    a_r = a;
    return
end

% KLT filter using KLT
if s(1)>s(2)
    t_mean = mean(a,1);
    C = (a'*a - s(1)*t_mean'*t_mean)/(s(1)-1);
    [V,D] = eig((C+C')/2);
    V_t = V'; % V_0 = V;
    V(:,1:round(N*(1-r))) = 0;
    V_in = (V*V_t);
    a_r = a*V_in' ;
else
    t_mean = mean(a,2);
    C = (a*a' - s(2)*t_mean*t_mean')/(s(2)-1);
    [V,D] = eig((C+C')/2);
    V_t = V'; %V_0 = V;
    V(:,1:round(N*(1-r))) = 0;
    V_in = (V*V_t);
    a_r = V_in*a ;
end

 










