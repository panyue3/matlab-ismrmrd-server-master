% Make a simple movie, just cut a circle from the original image and then
% make in a movie without any other process


function make_circle_movie(fname,N)
skip=0;
a=zeros(160,120);
fid = fopen(fname,'r'); 

[y,x]=meshgrid(1:120,1:160);
mask = ( sqrt((x-72).^2+(y-60).^2)<56 );
for i= 1:N
    i,
    for ss = 1:skip, a00=fread(fid,[160,120],'uchar'); end
    a00=0;  a00=fread(fid,[160,120],'uchar');      
    a0 = zeros(128,128);
    a00 = a00.*mask;
    a0(:,1:120) = a00(72-64:72+63,1:120);
%    image(63*a0/max(a0(:))), axis xy, axis image;
    imshow(4*a0/max(a0(:))) 
    M(i)=getframe;
    pause(0.1)
end
fclose(fid)
movie(M)
fname = sprintf('%s_mov',fname)
movie2avi(M,fname,'FPS',12); 