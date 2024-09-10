addpath Z:\Ding\matlab\041404
addpath Z:\Ding\matlab\042204

%fname = '2225_5166_90_0_0';
%[peak,ang] = find_mov_peak_ang(fname,14); size(peak), size(ang)
%for i=2225:2260; j = round(i*2.322); fname = sprintf('%d_%d_90_0_0',i,j),
%    [peak(i,1:301),ang_vel(i,1:2)] = find_mov_peak_ang(fname,14);
%end


for n=0:9, fname = sprintf('2252_5229_90_0_%d',n),
[px2252(1:150,1:301,n+1),py2252(1:150,1:301,n+1),px_re2252(1:150,1:301,n+1),py_re2252(1:150,1:301,n+1)]=find_041404_peak_position(fname);
c2252=0;
for i=1:301, px0 = px2252(:,i,n+1); py0 = py2252(:,i,n+1); 
    px = px0(find(px0>0)); py = py0(find(px0>0));
    n0 = length(px);b = ones(1,n0);
    c0 = try_2(b,px,py),
    c2252(i + (n)*301) =  c0; if n==1, break, end
end; end


%for n=1:10, fname = sprintf('2253_5231_90_0_%d',n),
%[px2253(1:150,1:301,n),py2253(1:150,1:301,n),px_re2253(1:150,1:301,n),py_re2253(1:150,1:301,n)]=find_041404_peak_position(fname);
%c2253=0;
%for i=1:301, px0 = px2253(:,i,n); py0 = py2253(:,i,n); 
%    px = px0(find(px0>0)); py = py0(find(px0>0));
%    n0 = length(px);b = ones(1,n0);
%    c0 = try_2(b,px,py);
%    c2253(i + (n-1)*301) =  c0;
%end; end


%for n=0:9, fname = sprintf('2254_5234_90_0_%d',n),
%[px2254(1:150,1:301,n+1),py2254(1:150,1:301,n+1),px_re2254(1:150,1:301,n+1),py_re2254(1:150,1:301,n+1)]=find_041404_peak_position(fname);
%c2254=0;
%for i=1:301, px0 = px2254(:,i,n); py0 = py2254(:,i,n); 
%    px = px0(find(px0>0)); py = py0(find(px0>0));
%    n0 = length(px);b = ones(1,n0);
%    c0 = try_2(b,px,py);
%    c2254(i + (n)*301) =  c0;
%end; end










