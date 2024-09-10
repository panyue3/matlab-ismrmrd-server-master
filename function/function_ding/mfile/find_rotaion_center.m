% Find the rotation center, generate a ring and do cross corrolation
% between the ring and the sum up images.
% function [x,y] = find_rotaion_center(fname,N);
% N is the totla number of images you want to add up.

function [x,y] = find_rotaion_center(fname,N);

fid = fopen(fname,'r');
for i=1:100,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
a0 = reshape_128_128_112103(a,'bilinear');
a = 0; a = sum(a0,3);   a0 = 0;     a = a- mean(a(:));figure(1), imagesc(a)
[x,y] = meshgrid(1:128,1:128);
j = 0;

for i=50:-0.5:30
    j = j + 1;
    a0 = exp(-( abs(sqrt((x-65).^2+(y-65).^2) -i) )/2); a0 = a0 - mean(a0(:));
    b(1:128,1:128,j) = my_corr2(a0,a)/i ; %surf(b(:,:,j)), pause
    c(j) = max(max(b(:,:,j)));
end
    j = find(c == max(c(:)))
    [x,y] = find(b(:,:,j) == max(c(:)));

