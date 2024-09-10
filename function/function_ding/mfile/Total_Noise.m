% This is to compute the total noise from the temporal subtraction method
% and then compare to the median eigenvalue.
% [n_temp, n_med] = Total_Noise(a)
% n_temp: noise std from temporal subtraction.
% n_med: noise from median eigenvalue. 


function [n_temp, n_med] = Total_Noise(a)

s = size(a);
N = s(3);

for i=1:N
    b(i, :) = reshape(a(:,:,i),1,s(1)*s(2)) - mean(mean( a(:,:,i) )); % Get rid of the mean of each image.
end
b_std = std(b,0,2); % Standard deviation of each image
A = (b*b'); % Covariance matrix for KLT
[V,D] = (eig(A)); % This is to diagonalize the covariance matrix

for i = 1:N % Get all the eigenvalue
    E_V(i) = D(i,i);
end
n_med = sqrt(median(E_V(:))/s(1)/s(2))  ;

A_0 = b*b'./(b_std'*b_std)/s(1)/s(2); %Normalized A

for i=1:N, c(i)=A_0(i,i); end % Find the lowest autocorrelation coefficients.
L = length(A_0(:)); % Total number of coefficients
Y = sort(A_0(:),'descend'); % Sort all the autocorrelation coefficients
[x,y] = find(A_0==Y(N+1) ); % Take 64 pairs, each pair twice
for i=1:1
    d(:,:)= a(:,:,x(i)) - a(:,:,y(i));
end
n_temp = std(d(:))/sqrt(2);






