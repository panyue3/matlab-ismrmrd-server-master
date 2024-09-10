% This is to get the eigenimage only
% [a_eigen,V,D] = KL_Eigenimage_with_Mean(a);

function [a,V,D] = KL_Eigenimage_with_Mean(a)

s = size(a);

if length(s) ==2, % 2-D case
    if s(2) > s(1), a = a'; end % first dimension is always larger
    s = size(a);
    %t_mean = mean(a,1);     
    %a_mean = ones(s(1),1)*t_mean;
    a_mean = 0;
    a = a - a_mean; %remove mean
    A = (a'*a)/(s(1)); %clear b;
    [V,D] = (eig((A+A')/2));
    %[V,D] = eig((A+A')/2, diag(ones(1,s(2))), 'chol'); % Diagonalize the covariance matrix
    a = (a + a_mean)*V;
elseif length(s)==3, % 3-D case
    % b = single(zeros(N,s(1)*s(2)));
    a = (reshape(a, [s(1)*s(2),s(3)] )); %clear a
    %t_mean = mean(a,1);     
    %a_mean = ones(s(1),1)*t_mean;
    a_mean = 0;
    a = a - a_mean; %remove mean
    A = (a'*a)/(s(1)*s(2)); %clear b;
    [V,D] = (eig((A+A')/2)); % Diagonalize the covariance matrix
    %[V,D] = eig((A+A')/2, diag(ones(1,s(3))), 'chol'); 
    V = (V);
    D = (D); % figure(2), semilogy(diag(D), 'x')
    a = (reshape( (a+a_mean)*V , [s(1),s(2),s(3)] ) ) ; clear b
    disp('KL_Eigenimage 3-D Data Finished')
else
    a = (reshape(a, [prod(s(1:end-1)),s(end)] )); %clear a
    %t_mean = mean(a,1);     
    %a_mean = ones(s(1),1)*t_mean;
    a_mean = 0;
    a = a - a_mean; %remove mean
    A = (a'*a)/prod(s(1:end-1)); %clear b;
    [V,D] = (eig((A+A')/2)); % Diagonalize the covariance matrix
    %[V,D] = eig((A+A')/2, diag(ones(1,s(3))), 'chol'); 
    V = (V);
    D = (D);
    a = (reshape( (a+a_mean)*V , s ) ) ; clear b
    disp('KL_Eigenimage N-D Data Finished')
end



% if length(s) ~=3,
%     'Input array is not a 3-D array!'
% else     
%     a = (reshape(a, [s(1)*s(2),s(3)] )); %clear a 
%     A = (a'*a)/(s(1)*s(2)); %clear b;
%     %clock,
%     [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
%     V = (V);
%     D = (D);  % figure(1), semilogy(diag(D), 'o')     
% 	a = (reshape( (a)*V , [s(1),s(2),s(3)] ) ) ; % Corrected 20180131 DingYu
% end










