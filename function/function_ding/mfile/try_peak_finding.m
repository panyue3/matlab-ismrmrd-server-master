

% Find the backgorund of the original image;
b = background(a,'bilinear');
% Make the illumination homogeneous
a = a./b ;
% Apply filters, median filter and wiener filter
a = medfilt2(a,[3,3]);
a = wiener2(a,[3,3]);
% Only keep the peaks 
a0 = a.*(a>1.5);
% Find where is the peak
p = imregionalmax(a0);
% Find the locak peak more precisely aound the peak position
position = find(p==1);

imshow(a,[]);
a = medfilt2(a,[5,5]);
a = wiener2(a,[3,3]);

% lp = [0 1 0; 1 -4 1; 0 1 0];
% conv2(a,lp,''same)
% strel('line',5,45)

a = (a>2.0).*a;
