% [k1,k2,k3] = rough3k(z4); find roughly what k is;

function [k1,k2,k3] =rough3k(z4);

z4 = z4 - mean(z4(:));

% find roughly what k is:
b0 = abs(fftshift(fft2(z4)));
%figure(2)
%imagesc(b0),meanb = mean(b0(:)), medianb = median(b0(:)),
b0 = b0-mean(b0(:));
[x0,y0]=size(z4);
cx0=floor(x0/2)+1;
cy0=floor(y0/2)+1;
[l,m] = size(z4);
if l==1 | m==1,
   b0sum = b0;
   'a'
else
    b0rt=xy2rt(b0,cx0,cy0,1:cx0,-pi:0.01:pi);
%   figure(1),imagesc(b0rt);
    
    maxk = find(b0rt == max(b0rt(:)));

    b0sum=sum(b0rt);
    b0sum(1:20)=0;
end

%figure(3)
%plot(b0sum,'o-')


k = peak1d(b0sum);


