% Find the peak position and the position of the peak in the reconstructed
% pattern. This one only work for the movie in 033104 because the center
% position and the edge position


function [px,py,px_re,py_re]=find_033104_peak_position(fname)

[b0,y0] =  background_mov(fname,16,16,'bilinear');
fid = fopen(fname,'r');

[x,y]=meshgrid(1:128,1:128);
mask = sqrt((x-65).^2+(y-67).^2)<57;

skip = 0;for i=1:skip,a00=fread(fid,[160,120],'uchar');  end
a00=fread(fid,[160,120],'uchar'); 
a00 = double(a00);
j = 0; rot=0;dis=0;
% xp = zeros(500,200);yp=xp; vx=xp;vy=xp;
px = zeros(150,301);
py = px; px_re = px; py_re = px;
while prod(size(a00))==19200,     
    %a00 = a00./b0;
    a0 = reshape_128_img(a00,b0,y0); 
    % figure(3), imagesc(a0)
    j = j+1,
    %c = clock; c(6)
    [px0,py0,px_re0,py_re0] = find_mov_peaks_circle_insert(a0,65,65,3200);
    %c = clock; c(6)
    
    n = length(px0);
    %size(px_re0)
    %px_re0(1:n)
    px(1:n,j) = px0;    
    py(1:n,j) = py0; 
    px_re(1:n,j) = px_re0'; 
    py_re(1:n,j) = py_re0' ;
    a00=fread(fid,[160,120],'uchar'); 
    pause(0.01)
    % break
end
fclose(fid)
