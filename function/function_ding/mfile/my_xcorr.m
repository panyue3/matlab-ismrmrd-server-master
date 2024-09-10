%  a_out = my_xcorr(a,b)

function a_out = my_xcorr(a,b)

a = a - mean(a(:)); 	b = b - mean(b(:));
afft = fft(a);		bfft = fft(b);
if (std(a)*std(b)*sqrt(length(a)*length(b))) >0 
    a_out = real(fftshift(ifft(afft.*conj(bfft))))./(std(a)*std(b)*sqrt(length(a)*length(b)));
else
    a_out = zeros(length(a));
end

