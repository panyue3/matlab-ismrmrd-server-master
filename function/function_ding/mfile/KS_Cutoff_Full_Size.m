% This is the algorith to search for the best cutoff and the best fit of
% the noise variance 
% Method: Kolmogorov-Smirnov goodness of fit
% [Cutoff, Variance] = KS_Cutoff_Full_Size(E, I_N)
% Cutoff: the number of kept eigenmode
% Variance: noise variance
% I_N = pixels in the image
% Note: it assume that length(E) = image number ; 
% No change of beta: k/N = (image #)/(pixe #)

function [Cutoff, Variance, ks] = KS_Cutoff_Full_Size(E, I_N)

s = size(E);
if ndims(E) > 2 % E is not a vector
    'Error! Eigenvalue is not a vector!',
    Cutoff = 0; Variance = 0;
    return
elseif ( (s(1) > 1) & (s(2) > 1) ) % E is not a vector
    'Error! Eigenvalue is not a vector!',
    Cutoff = 0; Variance = 0;
    return
else
    E = sort(E); % make sure it is in ascending order
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = length(E);
%k = ones(length(E), 64); % 
k = ones(length(E)); % 
sigma = zeros(1,length(E)); % 

for i = 3:n
    p = 0; p_temp = 0;
    sigma(i) = mean(E(1:i)); % This is the way to get the mean noise variance
    %for j=1:64
    j = 64;
        beta = min([1, i/(I_N*j/64 ) ]); % beta is a function of the noise mode number
        p = RMT_CDF( sigma(i), beta, E(1:i) );
        p_temp = (1:i)/i;
        %k(i,j) = max(abs( p - p_temp )); 
    %end
    k(i) = max(abs( p - p_temp )); 
    i = i;
end
[I, J] = find(k == min(k(:)));
%imagesc(log(k))
%min(k(:))
%J = J,
%find(k==min(k))
Cutoff = I;
Variance = sigma(I);
ks = min(k(:));
% figure, plot(k(:,J), '*-'), title('K-S Goodness of Fit')
% figure, plot(sigma,'+-'), title('Noise Variance')
% figure, imagesc(log(k))









