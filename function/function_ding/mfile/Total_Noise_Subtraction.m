% This is to get the noise measurements from the subtraction method. 32
% pairs will be generated from the x = Correlation_Image_Pairs(a). Then the
% std of each difference image will be calculated and find 16 smallest std
% value, the mean of the 16 smallest value is the mean noise std.
% [noise, x] = Total_noise_Subtraction(a, r)
% noise: 1-D array contains all the noise with different cutoff
% x: 16 pairs selected to do the subtraction
% a: Original image series,
% r: 1-D array of cutoff ratio

function [noise, x] = Total_Noise_Subtraction(a, r)

s = size(a);
y = Correlation_Image_Pairs(a);
for i=1:length(y), t =(a(:,:,y(1,i)) - a(:,:,y(2,i))); t_std(i) = std(t(:)); end
[c,d] = sort(t_std);
%x = y(:,d(1:(length(y)/2) )); % Find the 16 image pairs to get the noise measurements.
x = y; % use them all

for i=1:length(r)
    a_r = my_KL_reshape(a, r(i));
    t_std = 0; t=0;
    for j = 1:length(x)
        %t =(a_r(:,:,x(1,j)) - a_r(:,:,x(2,j))); 
        t =(a_r(2:20,2:20,x(1,j)) - a_r(2:20,2:20,x(2,j))); 
        t_std(j) = std(t(:));
    end
    noise(i) = mean(t_std);
    i,
end
    
        


