x = (1:256)/256 ;
k = 10 ;
a = sin(2*pi*k*x);
b = (fft(a));
figure(1)
plot(abs(b))
[m,l] =size(a);
D = zeros(l,l); k = 0;
for i = 2 :l-1, D(i,i)=-2;D(i,i-1) = 1; D(i,i+1) = 1; end ;

for i = 2 : l-1,
        k = -D*a'/(1/256)^2./(a)';
end

figure(2)
plot(k)
