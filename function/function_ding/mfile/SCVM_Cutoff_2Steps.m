% This is the algorith to search for the best cutoff and the best fit of
% the noise variance 
% Method: Kolmogorov-Smirnov goodness of fit
% Use two steps to optimize KS-test
% [Cutoff, Variance, scvm, beta] = SCVM_Cutoff_2Steps(E, I_N)
% Cutoff: the number of kept eigenmode
% Variance: noise variance
% I_N = pixels in the image
% Note: it assume that length(E) = image number ; 
% beta: k/N = (image #)/(pixe #)

function [Cutoff, Variance, scvm, beta, p_value, H] = SCVM_Cutoff_2Steps(E, I_N)

s = size(E);
if s(2)>s(1),E=E';end,

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
B_n = 256; % use 256 steps
k = ones(length(E), B_n); % 
sigma = zeros(1,length(E)); % 

t = 2:4:n ;
t_L = length(t);
N(1:2:t_L) = t(1:length(1:2:t_L) ); %Odd value searching forward
N(2:2:t_L) = t(end:-1:(end-length(2:2:t_L)+1) ); %even value searching backward
%N,

for i = 1:t_L
    p = 0; p_temp = 0;
    sigma(i) = mean( E(1:N(i) )); % This is the way to get the mean noise variance
    for j=1:8:B_n
        beta = min([1, N(i)/(I_N*j/B_n ) ]); % beta is a function of the noise mode number
        p = RMT_CDF( sigma(i), beta, E(1:N(i) ) );
        %p_temp = (1:i)/i;
        %k(i,j) = max(abs( p - p_temp )); 
        %E(1:i)
        if min(diff(p))<0, p=p, diff(p)*1000,max(p)-1, end
        [H, p_value, k(N(i),j)] = scvmtest( E(1:N(i) ), p ) ;
        %[H, p_value, k_0] = kstest2( E(1:i), p ) , %k(i,j) = k_0;
    end
    if (i > 4)& ( min(min(k(N(i-1:i),:))) > 2*min(min( k(N(1:i),:) )) ), break, end %i = i,
end, % i=i,t_L=t_L,
[I, J] = find(k == min(k(:))); %imagesc(k),colorbar % This this end of first step

if length(I)>1, I = I'; J = J'; I = round(median(I)); J = round(median(J)); end % Take care of multiple values

% Second step
for i = max([round(I(1)*0.875), I(1)-4,2]):min([round(I(1)*1.125), I(1)+4,n]) % Search 87.5% to 112.5% of cutoff
    p = 0; p_temp = 0;
    sigma(i) = mean(E(1:i)); % This is the way to get the mean noise variance
    for j=max([J-12,1]):min([J+12,256]) % Search 33 steps around the maximum value
        beta = min([1, i/(I_N*j/B_n ) ]); % beta is a function of the noise mode number
        p = RMT_CDF( sigma(i), beta, E(1:i) );
        %p_temp_1 = (1:i)/i;
        %k(i,j) =  max(abs( p - p_temp_1 )) ; 
        %[E(1:i),p']
        %E(1:i)'
        %p = p + (0.000001)*(1:length(p));
        if min(diff(p))<0, p=p, diff(p)*1000, max(p)-1, end
        [H, p_value, k(i,j)] = scvmtest( E(1:i), p ) ;
        %[H, p_value, k(i,j)] = kstest2( E(1:i), p ) ;
        
    end
    if min(k(i,:)) > 2*min(min(k(max([round(I(1)*0.875), I(1)-4,2]):i, max([J-12,1]):min([J+12,256]) ))), break, end %i = i,
end
[I, J] = find(k == min(k(:))); % This this end of first step
if length(I)>1,I = round(median(I)); J = round(median(J)); end % Take care of multiple values

%imagesc(log(k))
%min(k(:))
J = J,
beta = min([1, I(1)/(I_N*J(1)/B_n ) ]); % beta value for output
%find(k==min(k))
Cutoff = I;
Variance = (sigma(I)); % The sigma used in the RMT fitting 
ks = min(k(:));

% Begin For KS-test
p = 0;
p = RMT_CDF( sigma(I), beta, E(1:I) );
s = size(E); if s(2)>s(1),E=E';end, s = 0;
s = size(p); if s(2)>s(1),p=p';end 
[H, p_value, scvm] = scvmtest( E(1:I), p' ) ;
%[H, p_value, KSValue] = kstest( E(1:I), [E(1:I),p] ) ;
% ks = ks;
%End for KS-test










