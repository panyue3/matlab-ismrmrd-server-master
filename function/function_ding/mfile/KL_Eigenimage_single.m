% This is to get the eigenimage only
% [a_eigen,V,D] = KL_Eigenimage(a);

function [a_eigen,V,D] = KL_Eigenimage(a);

a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    b = single(zeros(N,s(1)*s(2)));
    b = (reshape(a, [s(1)*s(2),s(3)] )); %clear a
    t_mean = mean(b,1);
    b_mean = ones(s(1)*s(2),1)*t_mean;
    b = b - b_mean; clear b_mean
    b_std = std(b,0,1);
    A = (b'*b)/(s(1)*s(2)); %clear b;
    %clock,
    [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
    V = (V);
    D = (D);
    %clock,
    % Try to reconstruct the eigen images I. The first one (No.20) should be the mean
    %a_eigen = single(zeros(size(a)));
    %a_eigen = single(zeros(size(a)));
%     for i=1:N % the rest will not be used any way.
%         %temp = single(zeros(s(1),s(2)));
%         temp = (zeros(s(1),s(2)));
%         for j=1:N
%             temp = temp + V(j,i)*a(:,:,j);
%         end
%         a_eigen(:,:,i) = temp;
%     end

a_eigen = (reshape(b*V , [s(1),s(2),s(3)] ) ) ;, clear b

end










