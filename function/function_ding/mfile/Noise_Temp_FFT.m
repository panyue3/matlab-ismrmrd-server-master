% Try a new noise measurements tool, to get the FFT of each pixel and then
% use the high frequency part of it.

function noise = Noise_Temp_FFT(a, mask)

s = size(a);

b = (reshape(a, [s(1)*s(2),s(3)] )); a = 0;
t_mean = mean(b,1);
b_mean = ones(s(1)*s(2),1)*t_mean;
b = b - b_mean; clear b_mean

a = reshape(b, [s(1),s(2),s(3)] ); %imagesc(a(:,:,1)),

[x,y] = find(mask == 1);
for i = 1: sum(mask(:))
    t = fft(squeeze(a(x(i), y(i),:)));
    t_std(i) = sqrt(sum(abs( t( round(0.25*s(3):0.75*s(3) ) ).^2 ))/sum( round(0.25*s(3):0.75*s(3) )) );
end
    
noise = mean(t_std);







