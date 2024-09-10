% This is the algorith to search for the best cutoff and the best fit of
% the noise variance 
% Method: Kolmogorov-Smirnov goodness of fit
% [ Cutoff, Variance, ks, beta_ratio, p_value ] = KS_Cutoff_Eigenimages_2Steps(a)
% Cutoff: the number of kept eigenmode
% Variance: noise variance
% I_N = pixels in the image
% Note: it assume that length(E) = image number ; 
% beta: k/N (image #)/(pixe #)

function [ Cutoff, Variance, ks, beta_ratio, p_value ] = KS_Cutoff_Eigenimages_2Steps(a)

if ndims(a) ~= 3 % E is not a vector
    'Error! input data is not 3-D!',
    Cutoff = 0; Variance = 0; ks = 0;
    return
end

s = size(a);
I_N = s(1)*s(2);
b = reshape(a, s(1)*s(2), s(3)); clear a;
C = b'*b/I_N;
[V,D] = eig(C);
E = diag(D);

[ Cutoff, Variance, ks, beta_ratio, p_value, H] = KS_Cutoff_2Steps(E, I_N);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% n = length(E);
% k = ones(length(E), 64); % 
% sigma = zeros(1,length(E)); % 
% 
% for i = 3:n
%     p = 0; p_temp = 0;
%     sigma(i) = mean(E(1:i)); % This is the way to get the mean noise variance
%     for j=1:64
%         beta = min([1, i/(I_N*j/64 ) ]); % beta is a function of the noise mode number
%         p = RMT_CDF( sigma(i), beta, E(1:i) );
%         p_temp = (1:i)/i;
%         k(i,j) = max(abs( p - p_temp )); 
%     end
%     i = i;
% end
% [I, J] = find(k == min(k(:)));
% %imagesc(log(k))
% %min(k(:))
% %J = J,
% %find(k==min(k))
% Cutoff = I;
% Variance = sigma(I);
% ks = min(k(:));
% beta_ratio = J/64;
% % figure, plot(k(:,J), '*-'), title('K-S Goodness of Fit')
% % figure, plot(sigma,'+-'), title('Noise Variance')
% % figure, imagesc(log(k))

