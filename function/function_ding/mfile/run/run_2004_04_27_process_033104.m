%close all, clear all
addpath Z:\ding\matlab\033104


%for i=0:9, fname = sprintf('2230_5178_90_0_%d',i),
%[px2230(1:150,1:301,i+1),py2230(1:150,1:301,i+1),px_re2230(1:150,1:301,i+1),py_re2230(1:150,1:301,i+1)]=find_033104_peak_position(fname);
%end
%for j=1:10,  for i=1:301, px0 = px2230(:,i,j); py0 = py2230(:,i,j); 
%    px = px0(find(px0>0)); py = py0(find(px0>0));
%    n = length(px);b = ones(1,n);
%    c0 = try_2(b,px,py);
%    c2230(i+(j-1)*301) =  c0;
%end, end


for i=0:9, fname = sprintf('2235_5190_90_0_%d',i),
[px2235(1:150,1:301,i+1),py2235(1:150,1:301,i+1),px_re2235(1:150,1:301,i+1),py_re2235(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2235(:,i,j); py0 = py2235(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2235(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2240_5201_90_0_%d',i),
[px2240(1:150,1:301,i+1),py2240(1:150,1:301,i+1),px_re2240(1:150,1:301,i+1),py_re2240(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2240(:,i,j); py0 = py2240(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2240(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2245_5213_90_0_%d',i),
[px2245(1:150,1:301,i+1),py2245(1:150,1:301,i+1),px_re2245(1:150,1:301,i+1),py_re2245(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2245(:,i,j); py0 = py2245(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2245(i+(j-1)*301) =  c0;
end, end
 

for i=0:9, fname = sprintf('2250_5225_90_0_%d',i),
[px2250(1:150,1:301,i+1),py2250(1:150,1:301,i+1),px_re2250(1:150,1:301,i+1),py_re2250(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2250(:,i,j); py0 = py2250(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2250(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2255_5236_90_0_%d',i),
[px2255(1:150,1:301,i+1),py2255(1:150,1:301,i+1),px_re2255(1:150,1:301,i+1),py_re2255(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2255(:,i,j); py0 = py2255(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2255(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2260_5248_90_0_%d',i),
[px2260(1:150,1:301,i+1),py2260(1:150,1:301,i+1),px_re2260(1:150,1:301,i+1),py_re2260(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2260(:,i,j); py0 = py2260(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2260(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2265_5259_90_0_%d',i),
[px2265(1:150,1:301,i+1),py2265(1:150,1:301,i+1),px_re2265(1:150,1:301,i+1),py_re2265(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2265(:,i,j); py0 = py2265(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2265(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2270_5271_90_0_%d',i),
[px2270(1:150,1:301,i+1),py2270(1:150,1:301,i+1),px_re2270(1:150,1:301,i+1),py_re2270(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2270(:,i,j); py0 = py2270(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2270(i+(j-1)*301) =  c0;
end, end


for i=0:9, fname = sprintf('2275_5283_90_0_%d',i),
[px2275(1:150,1:301,i+1),py2275(1:150,1:301,i+1),px_re2275(1:150,1:301,i+1),py_re2275(1:150,1:301,i+1)]=find_033104_peak_position(fname);
end
for j=1:10,  for i=1:301, px0 = px2275(:,i,j); py0 = py2275(:,i,j); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2275(i+(j-1)*301) =  c0;
end, end




'Test Run finished '
