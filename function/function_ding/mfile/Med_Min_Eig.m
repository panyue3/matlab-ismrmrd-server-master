% This is the function to calculate the median and the min square root of eigenvalue of a
% data series.
% function [E_med, E_min] = Med_Min_Eig(a,b);


function [E_med, E_min] = Med_Min_Eig(a,b);

s = size(a);
for i=1:length(b) % b is the windo
    k = floor(s(3)/b(i)); % How many measurements I can have 
    for j=1:k
        a_t = 0;
        a_t = a(:,:, (j-1)*b(i)+1:j*b(i) );
        E_t(j,1:b(i)) = Eigenvalue(a_t);
    end
    %median(E_t,2),E_t;k
    E_med(1,i) = mean(median(sqrt(E_t),2));
    E_med(2,i) = std(median(sqrt(E_t),2));
    E_min(1,i) = mean(min(sqrt(E_t),[],2));
    E_min(2,i) = std(min(sqrt(E_t),[],2));
    E_t = 0;
end



