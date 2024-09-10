% The 1/(r^3) interaction between the spins
I = rand(128,128);
[x,y] = meshgrid(1:128,1:128); c = ones(128,128);
c0 = (sqrt((x-65).^2+(y-65).^2)).^3;
c0(65,65) = 1; c = c./c0; c(65,65) = 0;
c = c/sum(sum(c));
I = 2.*double(I > 0.5)-1 ; %figure(1), imagesc(I)
%imagesc(c)
for j=1:1,
%sum(sum(I))
T = abs(ifft2(fftshift(fft2(I)).*fftshift(conj(fft2(c)))));
I0 = I.*T; %figure(1), imagesc(I0)
I0 = double(1-2*(I0<0)); figure(1), imagesc(I0)
%b = rand(128,128);
I = I0.*I ; figure(2), imagesc(I),figure(4), imagesc(I0.*I)
%sum(sum(I))
figure(3),imagesc(I),j,%pause,
end

