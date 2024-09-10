% This is the algorith to search for the best cutoff and the best fit of
% the noise variance 
% Method: Kolmogorov-Smirnov goodness of fit
% [Cutoff, Variance, ks] = KS_Cutoff_Fix_N(E, I_N)
% Cutoff: the number of kept eigenmode
% Variance: noise variance
% I_N = pixels in the image
% Note: it assume that length(E) = image number ; 
% beta: k/N = (image #)/(pixe #)

function [Cutoff, Variance, ks, beta, p_value, H] = KS_Cutoff_Fix_N(E, I_N)

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
%B_n = 64; k = ones(length(E), B_n); %
k = ones(length(E), 1);
sigma = zeros(1,length(E)); % 

for i = 3:n
    p = 0; p_temp = 0;
    sigma(i) = mean(E(1:i)); % This is the way to get the mean noise variance
    beta = min([1, i/(I_N ) ]);
    p = RMT_CDF( sigma(i), beta, E(1:i) );
    if min(diff(p))<0, p=p, diff(p)*1000,max(p)-1, end % Get rid of the non-increase p
    [H, p_value, k(i)] = kstest( E(1:i), [E(1:i),p'] ) ;
end
I = find(k == min(k(:)));
beta = min([1, I/(I_N ) ]); % beta value for output

Cutoff = I;
Variance = sigma(I);
ks = min(k(:));

% Begin For KS-test
p = 0;
p = RMT_CDF( sigma(I), beta, E(1:I) );
s = size(E); if s(2)>s(1),E=E';end, s = 0;
s = size(p); if s(2)>s(1),p=p';end
[H, p_value, ks] = kstest( E(1:I), [E(1:I),p] ) ;









