% k-space convolution kernel 2D, find kernel c, that A conv c = B;
% Just one k-space, no channel direction
% 
% 2016-04-01 Ding Yu

function [c_img, A_matrix, B_matrix] = conv_kspace_2D(A_k, B_k, size_c)

s_A = size(A_k);
s_B = size(B_k);
c_img = zeros(s_A);
size_check = abs(s_A(1)-s_B(1)) + abs(s_A(2)-s_B(2));
if size_check > 0, 
    disp('size of Matrix A and B MUST match !, Aborting ...'), 
    return, 
elseif mod(size_c(1)*size_c(2), 2) == 0
    disp('size of Kernel c MUST be odd numbers, Aborting ...'), 
    return,
end

s_c_1 = size_c(1); % size of kernel c
s_c_2 = size_c(2);
c_center_1 = floor((s_c_1+1)/2); % center of kernel c
c_center_2 = floor((s_c_2+1)/2);
A_center_1 = floor(s_A(1)/2+1); % center of image A
A_center_2 = floor(s_A(2)/2+1);

A_matrix = zeros( (s_A(1)-s_c_1+1)*(s_A(2)-s_c_2), s_c_1*s_c_2 );
B_matrix = zeros( (s_A(1)-s_c_1+1)*(s_A(2)-s_c_2), 1 );

Counter = 0;
for i=1:s_A(1)-s_c_1+1
    for j = 1:s_A(2)-s_c_2
        Counter = Counter + 1;
        temp = A_k(i:i+s_c_1-1, j:j+s_c_2-1);
        A_matrix(Counter, :) = temp(:);
        temp = B_k(i:i+s_c_1-1, j:j+s_c_2-1);
        B_matrix(Counter) = temp(c_center_1, c_center_2);
    end
end

c_k = inv(A_matrix'*A_matrix)*(A_matrix'*B_matrix); % Penrose-Moore pseuo-inverse
c_k = reshape(c_k, s_c_1, s_c_2);
c_k_mirror = c_k(end:-1:1, end:-1:1);

c_img(A_center_1 + (1:s_c_1) - c_center_1, A_center_2 + (1:s_c_2) - c_center_2) = c_k_mirror;
c_img = fftshift(ifft2( ifftshift(c_img) ))*(prod(s_A));

