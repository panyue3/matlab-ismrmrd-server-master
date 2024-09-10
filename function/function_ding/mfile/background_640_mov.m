% find the backkground of the image b = background_640_mov(fname,m,n,method), 
% function [b0,y0]=background_640_mov(fname,m,n,method)
% the method is 'bilinear' or'bicubic', the mothod of function imresize. m
% and n is the block size you want to choose, it should be larger than 1/k.
% b is a 2D array, which is the background, the y0 is the position of the
% image, which is a useful paramenter in reshape_640_img(a,y0)

function [b0,y0]=background_640_mov(fname,m,n,method)

fid = fopen(fname,'r');  
a00=fread(fid,[640,480],'uchar');  
a00 = double(a00);
a(1:640,1:480) = a00;  i00=0;      
while prod(size(a00))==640*480,            
    a00=fread(fid,[640,480],'uchar');            
    if prod(size(a00))==640*480,  i00=i00 + 1;    a=a + a00;    end; 
    if i00 > 500, break, end
end
fclose(fid)
asize = size(a);
%bg16 = blkproc(a,[m,n],'mean(x(:))');
%b = imresize(bg16,[asize(1),asize(2)],method);
a = a.* (256./max(a(:)));

% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
ay = sum(a>1,2);
for i=1:129, ty(i) = sum(ay(i:i+511)); end 
y1 = find(max(ty)==ty);% figure(2),plot(ty), figure(1), imagesc(a), max(a(:))
y0 = floor(median(y1)); % May get more than one maxima,choose the one in the middle

% From now on, get the 128x128 background
a0(:,17:496)=a(y0:y0+511,1:480);
bg16 = blkproc(a0,[m,n],'mean(x(:))');
b0 = imresize(bg16,[512,512],method);