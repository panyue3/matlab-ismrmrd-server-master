function res = fft2c(x)
fctr = size(x,1)*size(x,2);
s = size(x);
if ( length(s) == 2 )
    res = 1/sqrt(fctr)*fftshift(fft2(ifftshift(x)));
end
if ( length(s) == 3 )
    for n=1:size(x,3)
        res(:,:,n) = 1/sqrt(fctr)*fftshift(fft2(ifftshift(x(:,:,n))));
    end
end
if ( length(s) == 4 )
    for s=1:size(x,4)
        for n=1:size(x,3)
            res(:,:,n,s) = 1/sqrt(fctr)*fftshift(fft2(ifftshift(x(:,:,n,s))));
        end
    end
end
 
