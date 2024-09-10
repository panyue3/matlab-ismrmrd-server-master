% This is to find the highly correlated image pairs from the correlation
% between them. Return 32 image pairs with highes correlation. No images
% are repeated. 

function x = Correlation_Image_Pairs(a)

s = size(a);
N = s(3);
b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
t_mean = mean(b,1);
b_mean = ones(s(1)*s(2),1)*t_mean;
b = b - b_mean; clear b_mean
b_std = std(b,0,1); % Standard deviation of each image% Standard deviation of each image

A_0 = b'*b./(b_std'*b_std)/s(1)/s(2); %Normalized A

for i=1:N, A_0(i,i)=0; end % suppress autocorrelation.

for i=1:32
    [t1, t2] = find( A_0 == max(A_0(:))  );
    x(1,i) = t1(1) ;
    x(2,i) = t2(1) ;
    A_0(x(:,i),:) = 0;
    A_0(:,x(:,i)) = 0;
end










