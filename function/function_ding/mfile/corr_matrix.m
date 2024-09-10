% This is to find the correlation matrix of a 2/3-D matrix. Explore the
% correlation between frames.
% function c = corr_matrix(a)

function c = corr_matrix(a)

a = single(a);
s = size(a);
c = 0;
if length(s) == 2,
    b = (zeros(s(2), s(1)));
    for i=1:s(2)
        temp = (a(:,i)); %size(temp), size(b)
        b(i,:) = (temp(:) -mean(temp(:)))/std(temp(:)); % 
    end
    c = b*b'/s(1); clear b;
    c = (c + c')/2; 
elseif length(s) == 3,
    N = s(3);
    b = (zeros(N,s(1)*s(2)));
    for i=1:N
        temp = (a(:,:,i));
        b(i, :) = (temp(:) -mean(temp(:)))/std(temp(:)); % 
    end
    c = b*b'/(s(1)*s(2)); clear b;
    c = (c + c')/2;  
else
    'Input array is not a 23-D array!'
    return
end








