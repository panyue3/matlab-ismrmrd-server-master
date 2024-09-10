% function a0 = readin_160_120_file(fname)
% Automatically read in all the frames, no other functions 

function a0 = readin_160_120_file(fname)

fid = fopen(fname,'r');     a0 = 0;     i00=1;      atotal = 0 ;        
% [x,y]=meshgrid(1:128,1:128);        
a00=fread(fid,[160,120],'uchar');        
a0(1:160,1:120,1) = a00;        
while prod(size(a00))==19200,            
    a00=fread(fid,[160,120],'uchar');            
    if prod(size(a00))==19200,  i00=i00 + 1;    a0(:,:,i00)=a00;    end;        
end
fclose(fid);


