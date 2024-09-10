% Find the image in the file
% [e, ecorr]=find_pattern(fname,number)

function [e, ecorr]=find_pattern(fname,number)

a0 = readin_160_120_file(fname);
a0 = reshape_128_128_093003(a0,0.0618);
afft(1:128,1:128) = abs(fftshift(fft2(a0(:,:,number))));
a = xy2rt(afft(:,:),65,65,1:50,0:pi/180:2*pi-0.001);
e = sum(a(:,19:23),2);  e = e - mean(e(:));
%efft = fft(e(:));
ecorr = my_xcorr(e,e);
%ecorr = real( ifft(efft.*conj(efft))./(std(e)^2*length(e))  );
a(:,1) = 0 ;
image_a(1:128,1:128) = a0(:,:,number);
figure(1), 
subplot(2,2,1), imagesc(image_a)
subplot(2,2,2), imagesc(a)
subplot(2,2,3), plot(e)
title('The Ring of Power Spectrum','FontSize',15)
subplot(2,2,4), plot(ecorr(:),'o-')
title('AutoCorrelation Function','FontSize',15)
figure(2), imagesc(a),
figure(3), plot(e),
figure(4), plot(ecorr),
figure(5), imagesc(image_a),colormap(gray), axis off
