function   findlock(af,peak);

N = 629;
temp = zeros(1,N);
temp(N-8:N) = af(peak-9:peak-1);
temp(1:10) = af(peak:peak+9);
figure(5)
size(ifft(temp))
a(:,1) = real(ifft(temp))';
a(:,2) = imag(ifft(temp))';
plot(a(:,1),'r-');
hold on
plot(a(:,2),'b-');
hold off
%plot(real(ifft(temp)),'r-');
%plot(imag(ifft(temp)));
title('Imag & Real(red color)');
figure(6)
temp2 = ifft(temp);
plot(rem(atan2(imag(temp2),real(temp2)),pi));
plot(atan2(imag(temp2),real(temp2)));
figure(7)
plot(abs(temp2))
