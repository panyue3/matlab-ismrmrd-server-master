function  realk = imgk(name);

a=imread(name); b=zeros(512,512);
size(a); a=double(a);
b(17:496,:)=double(a(:,1:512));
b=lpfilter(b,0.5);
b = b-mean(b(:));
c = abs(fftshift(fft2(b)));
d = xy2rt(c,257,257,1:100,0:0.1:2*pi);
%figure(2);imagesc(b),
e = sum(d,1).*(1:100);
e(1:5)=0;
%figure(1),plot(e)
k = peak1d(e),
realk=k*2*pi/(512*0.02);
sprintf('%0.5g cm-1',realk)
