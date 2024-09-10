
function movie_120503(fname)

a = readin_160_120_file(fname);
a1 = reshape_128_128_112103(a);
a_size = size(a);
%for i=1:1, i, imagesc(a1(:,:,i)), axis xy, axis image, end, imagesc(sum(a1,3)), axis image,axis xy,

for j=1:a_size(3)
    colormap(gray);
    imshow(a1(:,:,j)), axis xy, axis image,axis off;
    M(j) = getframe;
end
clear a, clear a1,
% movie(M)
movie2avi(M,sprintf('%s.%s',fname,'avi'),'FPS',5)
close all
clear all
