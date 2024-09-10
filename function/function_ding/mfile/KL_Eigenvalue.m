% This is to get the eigenvector & eigenvalue only
% [V,D] = KL_Eigenvalue(a);

%function [V, D, D_1] = KL_Eigenvalue(a);
function [V, D] = KL_Eigenvalue(a);
%a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    %b = single(zeros(N,s(1)*s(2)));
    a = double(reshape(a, [s(1)*s(2),s(3)] )); %clear a
%    t_mean = mean(a,1);
%    a_mean = ones(s(1)*s(2),1)*t_mean;  %a_mean=0;
%    A = ((a - a_mean)'*(a - a_mean))/(s(1)*s(2)-1); clear a_mean , clear t_mean %clear b;
%     [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
%     V = (V); D = (D);
%     % Remove temporal mean instead of spatial mean
%     t_mean = mean(a,2);
%     a_mean = t_mean*ones(1,s(3));
%     A = ((a - a_mean)'*(a - a_mean))/(s(1)*s(2)); clear a_mean , clear t_mean 
    A = a'*a/(s(1)*s(2));
    [V,D] = (eig((A+A')/2));
%    [V,D] = eig(A, 'nobalance');
    %clock,
    %a = (reshape(a*V , [s(1),s(2),s(3)] ) ) ;, clear b
end










