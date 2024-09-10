% This is to find the gradient or numeric differentiation of the a 1D array. 
% function my_diff(p,n)
% p is the input array, n is the length of the points you want to use on
% one side of the point you wnt to calculate the differentiation

function s = my_diff(p,n)

L = length(p);
for i0=1:L-2*n
    i = i0 + n;
    s0 = polyfit(i-n:i+n,p(i-n:i+n),1);
    s(i) = s0(1);
    s0 = 0;
end
