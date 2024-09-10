% This is to calculation the noise from the std of a region defined by the
% mask.

function noise = Noise_Subtract_Temp_Mean(a, mask)

s = size(a);

b = (reshape(a, [s(1)*s(2),s(3)] )); a = 0;
t_mean = mean(b,1);
b_mean = ones(s(1)*s(2),1)*t_mean;
b = b - b_mean; clear b_mean

a = reshape(b, [s(1),s(2),s(3)] ); %imagesc(a(:,:,1)),

[x,y] = find(mask == 1);
for i = 1: sum(mask(:))
    t_std(i) = std(a(x(i), y(i),:));
end
    
noise = mean(t_std);
