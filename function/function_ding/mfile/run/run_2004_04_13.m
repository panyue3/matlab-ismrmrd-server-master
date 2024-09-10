addpath 033104

fname = '2230_5178_90_0_0'
[px2230,py2230,px_re2230,py_re2230]=find_033104_peak_position(fname);
c2230=0;
for i=1:301, px0 = px2230(:,i); py0 = py2230(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2230(i) =  c0;
end

fname = '2235_5190_90_0_0'
[px2235,py2235,px_re2235,py_re2235]=find_033104_peak_position(fname);
c2235=0;
for i=1:301, px0 = px2235(:,i); py0 = py2235(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2235(i) =  c0;
end

fname = '2240_5201_90_0_0'
[px2240,py2240,px_re2240,py_re2240]=find_033104_peak_position(fname);
c2240=0;
for i=1:301, px0 = px2240(:,i); py0 = py2240(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2240(i) =  c0;
end

fname = '2245_5213_90_0_0'
[px2245,py2245,px_re2245,py_re2245]=find_033104_peak_position(fname);
c2245=0;
for i=1:301, px0 = px2245(:,i); py0 = py2245(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2245(i) =  c0;
end

fname = '2250_5225_90_0_0'
[px2250,py2250,px_re2250,py_re2250]=find_033104_peak_position(fname);
c2250=0;
for i=1:301, px0 = px2250(:,i); py0 = py2250(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2250(i) =  c0;
end

fname = '2255_5236_90_0_0'
[px2255,py2255,px_re2255,py_re2255]=find_033104_peak_position(fname);
c2255=0;
for i=1:301, px0 = px2255(:,i); py0 = py2255(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2255(i) =  c0;
end

fname = '2260_5248_90_0_0'
[px2260,py2260,px_re2260,py_re2260]=find_033104_peak_position(fname);
c2260=0;
for i=1:301, px0 = px2260(:,i); py0 = py2260(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2260(i) =  c0;
end

fname = '2265_5259_90_0_0'
[px2265,py2265,px_re2265,py_re2265]=find_033104_peak_position(fname);
c2265=0;
for i=1:301, px0 = px2265(:,i); py0 = py2265(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2265(i) =  c0;
end

fname = '2275_5283_90_0_0'
[px2275,py2275,px_re2275,py_re2275]=find_033104_peak_position(fname);
c2275=0;
for i=1:301, px0 = px2275(:,i); py0 = py2275(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2275(i) =  c0;
end


fname = '2280_5294_90_0_0'
[px2280,py2280,px_re2280,py_re2280]=find_033104_peak_position(fname);
c2280=0;
for i=1:301, px0 = px2280(:,i); py0 = py2280(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2280(i) =  c0;
end

fname = '2270_5271_90_0_0'
[px2270,py2270,px_re2270,py_re2270]=find_033104_peak_position(fname);
c2270=0;
for i=1:301, px0 = px2270(:,i); py0 = py2270(:,i); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n = length(px);b = ones(1,n);
    c0 = try_2(b,px,py);
    c2270(i) =  c0;
end

