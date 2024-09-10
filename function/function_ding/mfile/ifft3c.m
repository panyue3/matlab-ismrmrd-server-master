function res = ifft2c(x)

S = size(x);
fctr = S(1)*S(2)*S(3);

x = reshape(x,S(1),S(2),S(3),prod(S(4:end)));

res = zeros(size(x));
for n=1:size(x,4)
res(:,:,:,n) = sqrt(fctr)*fftshift(ifftn(ifftshift(x(:,:,:,n))));
end


res = reshape(res,S);

