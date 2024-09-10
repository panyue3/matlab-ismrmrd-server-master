clear all;close all;
a = imread('lion','jpg');
[x,y] = meshgrid(1:2592/1024:2592,1:1944/768:1944);
for i=1:3
    b = a(:,:,i);
    b = double(b);
    c(768:-1:1,1:1024,i)=interp2(b,x,y);
end
clear x, clear y, clear a,
%figure(2),hist(c(:),1:256)
c = ((sqrt(c+1).*16)-15)*2.0 ; 
% c = (c+1)*4 ;
c = uint8(c);image(c), axis xy, axis image, axis off
clear b, clear i,