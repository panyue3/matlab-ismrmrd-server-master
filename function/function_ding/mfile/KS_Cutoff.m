% This is the algorith to search for the best cutoff and the best fit of
% the noise variance 
% Method: Kolmogorov-Smirnov goodness of fit
% [Cutoff, Variance, ks, beta] = KS_Cutoff(E, I_N)
% Cutoff: the number of kept eigenmode
% Variance: noise variance
% I_N = pixels in the image
% Note: it assume that length(E) = image number ; 
% beta: k/N = (image #)/(pixe #)

function [Cutoff, Variance, ks, beta] = KS_Cutoff(E, I_N)

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
%B_n = 64;
B_n = 256;
k = ones(length(E), B_n); % 
sigma = zeros(1,length(E)); % 

for i = 3:n
    p = 0; p_temp = 0;
    sigma(i) = mean(E(1:i)); % This is the way to get the mean noise variance
    for j=1:B_n
        beta = min([1, i/(I_N*j/B_n ) ]); % beta is a function of the noise mode number
        p = RMT_CDF( sigma(i), beta, E(1:i) );
        p_temp = (1:i)/i;
        k(i,j) = max(abs( p - p_temp )); 
    end
    i = i;
end
[I, J] = find(k == min(k(:)));
%imagesc(log(k)), colorbar
%min(k(:))
J = J(1);
beta = min([1, I(1)/(I_N*J(1)/B_n ) ]); % beta value for output
%find(k==min(k))
Cutoff = I(1);
Variance = sigma(I(1));
ks = min(k(:));
% figure, plot(k(:,J), '*-'), title('K-S Goodness of Fit')
% figure, plot(sigma,'+-'), title('Noise Variance')
% figure, imagesc(log(k))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% % Use searching algorithm to optimize it.
% n = length(E);
% %k = ones(length(E)); % 
% sigma = zeros(1,length(E)); % 
% 
% cutoff_temp = round(n/4); % Initial the best cutoff_temp = n/2;
% previous_cutoff = cutoff_temp; % This is the shift register, previous cutoff 
% for i =1:4 % only interate 4 times.
%     i = i, pause(0.01)
%     % Find the optimal beta
%     clear k; k = 1;
%     cutoff_temp = cutoff_temp
%     for j=1:256 % Looping beta which has 256 steps
%         p = 0; p_temp = 0;
%         sigma = mean(E(1:cutoff_temp));
%         beta = n /(I_N*(257-j)/256 ); % Initial the best cutoff_temp = n/2; 
%         p = RMT_CDF( sigma, beta, E(1:cutoff_temp) );
%         p_temp = (1:cutoff_temp)/cutoff_temp; % The pdf of the eigenvalues
%         k(j) = max(abs( p - p_temp ));
%         J = find( k == min(k(:)) ) ; % Find the optimal beta
% %         % Now find the criterion to stop searching
% %         if (j > 32)&( min(k(1:j-16)) < mean(k(j-15:j)) ) % Median of last 8 is larger than min of before
% %             min_k = min(k),
% %             break;
% %         end
%     end
%     %min_k = min(k),
%     %k = k,
%     %figure(1), plot(k,'*'), title(num2str(i))
%     J = J,
%     beta = min([1, n/(I_N*(257-J)/256 ) ]), % beta is a function of the noise mode number
%     % find the optimal cutoff
%     clear k; k(1:2) = 1;
%     for j = 3:length(E)
%         p = 0; p_temp = 0;
%         sigma = mean(E(1:j)); % This is the way to get the mean noise variance
%         p = RMT_CDF( sigma, beta, E(1:j) );
%         %p = RMT_CDF( sigma, n/(I_N), E(1:j) );
%         p_temp = (1:j)/j;
%         k(j) = max(abs( p - p_temp )); 
%         cutoff_temp = find( k == min(k(3:j)) ); % Find the optimal cutoff
% %         if (j > 32)&( min(k(3:j-16)) < mean(k(j-15:j)) ) % Median of last 8 is larger than min of before
% %             min_k = min(k(3:j)),
% %             k = k;
% %             break;
% %         end
%     end
%     %figure(2), figure, plot(k, '*-'), pause
%     min_k = min(k(3:j)),
%     %cutoff_temp = cutoff_temp,
%     if (cutoff_temp == previous_cutoff)
%         break
%     else
%         previous_cutoff = cutoff_temp;
%     end
% end
% %[I, J] = find(k == min(k(:))),
% %min(k)
% 
% %find(k==min(k))
% min_k = min(k(:))
% Cutoff = cutoff_temp;
% Variance = mean(E(1:cutoff_temp));
% beta = beta
% figure(3), figure, plot(k, '*-'), title('K-S Goodness of Fit')
% %figure, plot(sigma,'+-'), title('Noise Variance')
% %figure, surf(k)
% 










