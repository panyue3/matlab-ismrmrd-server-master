% This is to get the eigenvalue of a series of images.


function E = Eigenvalue(a)
s = size(a);
b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
t_mean = mean(b,1);
b_mean = ones(s(1)*s(2),1)*t_mean;
b = b - b_mean; %clear b_mean
b_std = std(b,0,1);
A = (b'*b)/(s(1)*s(2)); % clear b; % Imagesc(A), pause,
%        clock-c0,
[V,D] = (eig(A)); % This is to diagonalize the covariance matrix

for i=1:s(3), E(s(3)+1-i) = D(i,i); end
