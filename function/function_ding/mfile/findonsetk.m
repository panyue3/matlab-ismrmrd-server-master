j=10;

for i=1:7,
    fname=sprintf('%d%d%s',0,j,'.bmp'),
    j=j+1;
    k(j)=imgk(fname);
    
end

k=k*2*pi/(512*0.022);
clear i, clear j, clear fname,