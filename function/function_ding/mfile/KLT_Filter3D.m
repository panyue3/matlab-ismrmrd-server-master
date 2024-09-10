% This is KLT Filter function, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep [a_r,V_0,D] = KLT_Filter3D(a,r), a is
% a 3-D array, the third dimension is the frame number, r is a number
% smaller than 1.0, that is the ratio of the eign images you want to keep.
% This version has the FAST algorithm: Don't calculate the Eigen Images. 

function [a_r,V_0,D] = KLT_Filter3D(a,r);
%c0 = clock

s = size(a);
N = s(3);
if length(s) ~=3,
    'Error: Input array is not a 3-D array!'
    a_r = a;
    return
end
if r>1|r<=0
    'Error: The ratio must belong to (0 1]'
    a_r = a;
    return
end

b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
t_mean = mean(b,1);
%A = (b'*b - s(1)*s(2)*t_mean'*t_mean)/(s(1)*s(2)-1); % It may be problematic
A = (b'*b )/(s(1)*s(2)-1);
[V,D] = eig((A + A')/2); % This is to diagonalize the covariance matrix
V_0 = V;
% The advantage of this method is: it does not calculate the
% eigenimage, but use V_in =\tilda{V}*V'.
% V_in is the inverse matrix of V (orthogonal matrix)
V_t = V';
V(:,1:round(N*(1-r))) = 0; {N*(1-r), N*(r),N};
V_in = (V*V_t);
%a_r = (reshape(b*V_in' + b_mean, [s(1),s(2),s(3)] ) ) ;
a_r = (reshape(b*V_in', [s(1),s(2),s(3)] ) ) ;





