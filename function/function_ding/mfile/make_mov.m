% function make_movie(fname,N), N is the number of images

function make_movie(fname,N)
skip=0;
a=zeros(160,120);
fid = fopen(fname,'r'); for i=1:40, a=a+fread(fid,[160,120],'uchar');end, fclose(fid)
a =a./40 ;
a01 = a > 1 ; % This is the region where it has information.
% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
ay = sum(a01,2);
for i=1:33, ty(i) = sum(ay(i:i+127)); end 
y0 = floor(median(find(max(ty)==ty))); % May get more than one maxima,choose the one in the middle

a02 = ones(128,128).*median(a(:));
a02(:,5:124) = a(y0:y0+127,1:120);
bg16 = blkproc(a02,[16,16],'mean(x(:))');
bg128 = imresize(bg16,[128,128],'bilinear'); 
if min(bg128(:))==0, bg128 = bg128 + 0.01*max(bg128(:));  end
clear bg16, clear a02, clear ay, clear a01, clear a0,clear a;

fid = fopen(fname,'r');  
for i= 1:N
    i,
    for ss = 1:skip, a00=fread(fid,[160,120],'uchar'); end
    a00=0;  a00=fread(fid,[160,120],'uchar');      
    a0 = zeros(128,128);        a0(:,5:124)=a00(y0:y0+127,1:120);
    % The next for looop is to smooth the boundary
    for j=2:4
    a0(1:128,j) = a0(1:128,j) + 0.5^(5-j)*( a0(1:128,5) - a0(1:128,1) ) ;  
    a0(1:128,129-j) = a0(1:128,129-j) + 0.5^(5-j)*( a0(1:128,124) - a0(1:128,128) ) ; 
    end
    a1_0 = a0(:,:)./bg128; 
    
    %a0 =1-(a0<64);imagesc(xy2rt(a0,65,65,1:60,0:pi/180:2*pi-0.001)), axis xy,  colormap(gray) 
    
    imshow(4*a1_0/max(a1_0(:)))
    M(i)=getframe;
    pause(0.01)
end
fclose(fid)
%movie(M)
fname = sprintf('%s_mov',fname)
movie2avi(M,fname,'FPS',12); 

