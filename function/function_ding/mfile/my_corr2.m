%  a_out = my_corr2(a,b)

function a_out = my_corr2(a,b)

a = a - mean(a(:)); 	b = b - mean(b(:));
afft = fft2(a);		    bfft = fft2(b);  % figure(1),imagesc(abs(fftshift(afft))),figure(2),imagesc(abs(fftshift(bfft)))
asize = size(a);        bsize = size(b);
if (std(a(:))*std(b(:))) >0 
    a_out = real(fftshift(ifft2((afft.*conj(bfft)))))./(std(a(:))*std(b(:))*sqrt(asize(1)*asize(2)*bsize(1)*bsize(2)));
else
    a_out = zeros(size(a));'something is wrong in my_corr2'
end

% max(a_out(:)) 

