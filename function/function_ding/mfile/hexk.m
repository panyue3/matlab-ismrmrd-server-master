function ph=hexk(nm)

 all clear;

name=sprintf('/usr/home/lab/shared/ding/data/Dec01/122001/%s.png',nm);
a = imread(name);
a = double(a);
%figure(1);
imagesc(a);%
b = a(100:356,200:456);
b = b - min(b(:));
b = b - mean(b(:));

figure(1);
imagesc(b);

f=fftshift(abs(fft2(b)));
figure(2);
imagesc(f);
frt = xy2rt(f,129,129,0:100,0:0.1:2*pi);
figure(3);
imagesc(frt);
figure(4);
plot(sum(frt));

d = sum(frt);
for i = 1:10
d(i) =10;
end
find(max(d)==d)
