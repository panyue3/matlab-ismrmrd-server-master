addpath temp_sen_pos\old
%rmpath temp_sen_pos\new
fid = fopen('1450_3367_90_0_32','r');
for i=1:232, fread(fid,[160,120],'uchar'); end
for i=1:10,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
a0 = reshape_128_128_112103(a,'bicubic'); a=0;
a1 = 0; a1 =  sum(a0,3); asize = size(a0); 
for i=1:asize(3)  
    i,i+232,
    figure(1), imagesc(a0(:,:,i)), axis xy, axis image
    b(1:360,1:60)=(xy2rt(a0(:,:,i),64.5,65.5,1:60,0:pi/180:2*pi-0.0001));, figure(2),imagesc(b),pause
end 