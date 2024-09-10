%
% k = roughk(z4); find roughly what k is;
%

function k =roughk(z4); 

z4 = z4 - mean(z4(:));

% find roughly what k is:
b0 = abs(fftshift(fft2(z4)));   
%figure(2)
%imagesc(b0),,
[x0,y0]=size(z4);
cx0=floor(x0/2)+1;
cy0=floor(y0/2)+1;
if x0 <=y0, l0 = cx0-2;else l0=cy0-2;end
[l,m] = size(z4);
if l==1 | m==1,
   b0sum = b0;
   'a'
else
    b0rt=xy2rt(b0,cy0,cx0,1:l0,-pi:0.01:pi);
%   figure(1),imagesc(b0rt);
    b0sum=sum(b0rt).*(1:l0); 
    b0sum(1:5)=0;
end

%figure(1), plot(b0sum)

k = peak1d(b0sum);

