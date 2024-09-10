% find the backkground of the image b = background(a,m,n,method), 
% the method is 'bilinear' or'bicubic', the mothod of function imresize. m
% and n is the block size you want to choose, it should be larger than 1/k.

function b=background_640_img(a,m,n,method)

asize = size(a);
bg16 = blkproc(a,[m,n],'mean(x(:))');
b = imresize(bg16,[asize(1),asize(2)],method);
