% Try peak finding of a image, input is a 2d imgae, the output is the
% binary image only made of peaks and an array made of the position of the
% peak

function [a,b] = find_image_peak(a0)

a_size = size(a0);
b0 = (a0 > 2);      
se = strel('disk',1);   b0 = imerode(b0,se);
b = b0.*a0;
i=1;
while sum(b(:))~=0
    max_a = max(b(:));
    [x,y] = find(b == max_a(1));
    low_1 = max(x-3,1);         low_2 = max(y-3,1);
    high_1 = min(x+3,a_size(1));high_2 = min(y+3,a_size(2));
    a_sec = a0(low_1:high_1,low_2:high_2);
    [y0,x0]=peak2d(a_sec);      x0 = x0+x-2;    y0 = y0+y-2;
    a(i,1)=x0;      a(i,2)=y0;
    x0 = round(x0); y0 = round(y0);
    low_1 = max(x0-4,1);            low_2 = max(y0-4,1);
    high_1 = min(x0+4,a_size(1));   high_2 = min(y0+4,a_size(2));
    b0(low_1:high_1,low_2:high_2)=0;
   %imagesc(b0), pause(0.1)
    b = b0.*a0;
    i=i+1;
end


