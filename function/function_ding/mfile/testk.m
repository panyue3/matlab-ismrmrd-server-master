a = imread('a2.bmp');
a = double(a);
[x,y] = meshgrid(1:480,1:640); 
mask = (sqrt((x-240).^2+(y-320).^2)< 222);
mask = mask';
pts=find(mask==0);
am = mean(a(pts));
a = a.*mask;
mask=1-mask;
mask=mask*am;
a=a+mask;
b0(1:480,1:512) =a(1:480,71:582);
b0(481:512,:)=am;
%figure(5)
%b0 = b0./lpfilter(b0,0.01,0.02);
%img(b0);

%b0 = bpfilter(b0,0.09,0.99);
w=hanning(512);v=w;
win = w*v';
b0 = b0.*win;
%b0 = b0 -mean(b0(:));

figure(1)
img(b0)

c0 = deci(b0,2);
c0 = embed(c0,2);
d0 = abs(fftshift(fft2(c0)));
[x,y] = meshgrid(1:512,1:512);
figure(2)
img(d0)
rt = xy2rt(d0,257,257,1:256,0:0.01:2*pi);
rt(:,1:15)=0;
figure(3)
imagesc(rt)
sumt = sum(rt);
figure(4)
plot(sumt.*(1:length(sumt)));
