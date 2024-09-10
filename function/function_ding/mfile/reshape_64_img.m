% Reshape a individual image fom original size 160*120 to 128*128. 
% function a = reshape_128_img(a0,b,y0); a0 is the input image, b is the background, 
% y0 is the position of the illuminated part of the image, b0 and y0 is from
% the the function : [b0,y0]=background_mov(fname,m,n,method)

function a0 = reshape_64_img(a,b0,y0)

a = double(a);
% Get rid of the zeros in the background
b0 = b0-min(b0(:)) + 0.001*max(b0(:));

% Get the scaled image
asize = size(a);
a0 = zeros(64,64); 
a0(:,3:62)=a(y0:y0+63,1:60);
a0 = a0./b0;

% Smooth the boundary
a0(1:64,2) = a0(1:64,2) + 0.5*( a0(1:64,3) - a0(1:64,1) ) ;  
a0(1:64,63) = a0(1:64,63) + 0.5*( a0(1:64,62) - a0(1:64,64) ) ; 

