
function temp_f = Patch_Selection(A, B, varargin)

%option = varargin;
option = [];
if isfield(option, 'x_win')
    x_win = option.x_win;
else
    x_win = 32;
end
if isfield(option, 'y_win')
    y_win = option.y_win;
else
    y_win = 32;
end
if isfield(option, 'n_frames')
    n_frames = option.n_frames;
else
    n_frames = 20;
end

s_A = size(A);
s_B = size(B);
% Zero-pad B to the size of A
B_padded = zeros(s_A(1), s_A(2));
B_padded( s_A(1)/2+(-s_B(1)/2+1:s_B(1)/2),  s_A(2)/2+(-s_B(2)/2+1:s_B(2)/2)) = (B - mean(B(:)))/std(B(:));
C_padded = zeros(s_A(1), s_A(2));
C_padded( s_A(1)/2+(-s_B(1)/2+1:s_B(1)/2),  s_A(2)/2+(-s_B(2)/2+1:s_B(2)/2)) = ones(size(B));
N = prod(s_B(1)*s_B(2));

% Mask to get rid of zeros:
A_mean = mean(A(:));
Mask_0 = A > 0.01*A_mean;
%for i=1:s_A(3), figure(1), imagesc(Mask_0(:,:,i)), axis image, title(num2str(i)), pause, end 

if length(s_A) == 2 % only one 2-D array
    s_A(3) = 1;
end

% Compute the 2D FFTs
A_fft = fft2(A);
A2_fft = fft2(abs(A).^2);

B_fft = fft2(B_padded);
C_fft = fft2(C_padded);
Square_B = sum(B(:).*conj(B(:)));
corr_B = zeros(size(A)) ;

for i=1:s_A(3) 
    % Multiply the FFTs element-wise
    product_fft_AB = (A_fft(:,:,i) .* conj(B_fft));
    product_fft_AC = (A_fft(:,:,i) .* (C_fft));
    product_fft_A2C = (A2_fft(:,:,i) .* (C_fft));
    % Compute the inverse 2D FFT
    conv_B = fftshift((ifft2(product_fft_AB))).*Mask_0(:,:,i);
    Mean_A = (fftshift(real(ifft2(product_fft_AC)))).*Mask_0(:,:,i);
    Square_A = abs(fftshift(real(ifft2(product_fft_A2C))) - Mean_A.^2) + 10*eps;
    % std_A = sqrt( (Square_A/N) - mu_A.^2 );
    corr_B(:,:,i) = abs(conv_B - Mean_A)./sqrt(Square_A);
    
end

% Linearize the array and sort it in descending order
[sorted_c, linearInd] = sort(corr_B(:), 'descend');

% Extract the first 32 largest elements and their linear indices
top_n_values = sorted_c(1:n_frames);
top_n_linearInd = linearInd(1:n_frames);

% Convert linear indices to subscripts
[I, J, K] = ind2sub(size(corr_B), top_n_linearInd);

% Coordinate of the Patches
x_index = [-s_B(1)/2:s_B(1)/2-1];
y_index = [-s_B(2)/2:s_B(2)/2-1];

a_0 = zeros(s_B(1), s_B(2), n_frames);

for i=1:n_frames
    X = mod(I(i) + x_index -1, s_A(1)) + 1;
    Y = mod(J(i)+y_index -1, s_A(2)) + 1; 
    a_0(:,:,i) = A( X, Y, K(i) );
end
temp_f = KW_Filter_Adam(a_0);

close all
%for i=1:s_A(3), figure(1), imagesc(corr_B(:,:,i)), axis image, colorbar, pause, end
for i=1:s_A(3), figure(1), imagesc([a_0(:,:,i), temp_f(:,:,i)]), axis image, colorbar, pause, end







