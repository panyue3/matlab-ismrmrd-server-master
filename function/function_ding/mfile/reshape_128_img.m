% Reshape a individual image fom original size 160*120 to 128*128. 
% function a = reshape_128_img(a0,b,y0); a0 is the input image, b is the background, 
% y0 is the position of the illuminated part of the image, b0 and y0 is from
% the the function : [b0,y0]=background_mov(fname,m,n,method)

function a0 = reshape_128_img(a,b0,y0)

a = double(a);
% Get rid of the zeros in the background
b0 = b0-min(b0(:)) + 0.001*max(b0(:));
b00 = ones(128,128,1);
% Get the scaled image
%a = a./b;
asize = size(a);
a0 = zeros(128,128);
%for i=1:asize(3)
a0(:,5:124)=a(y0:y0+127,1:120);
a0(1:128,1:128) = a0(1:128,1:128)./b0;
%end
% Smooth the boundary
for i=2:4
    a0(1:128,i,:) = a0(1:128,i,:) + 0.5^(5-i)*( a0(1:128,5,:) - a0(1:128,1,:) ) ;  
    a0(1:128,129-i,:) = a0(1:128,129-i,:) + 0.5^(5-i)*( a0(1:128,124,:) - a0(1:128,128,:) ) ; 
end
