% This is the function F_10 in Womersley's paper
% y = F_10(alpha)
% alpha : Womersley Number

function y = F_10(a)

j = sqrt(-1);
L = prod(size(a));
alpha = reshape(a,L,1);
y_0 = zeros(L,1);
for i=1:L
    if alpha(i)==0;
        y_0(i) = 1.0001; % This is to avoid the sigularities in 1./(1-F_10) 
    else
        y_0(i) = [2*besselj(1,j^(3/2)*alpha(i))]./[alpha(i).*j^(3/2).*besselj(0,alpha(i)*j^(3/2))];
    end
end

y = reshape(y_0,size(a));