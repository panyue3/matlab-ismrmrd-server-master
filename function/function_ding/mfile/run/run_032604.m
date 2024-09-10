addpath 121303
fid = fopen('1456_3381_90_0_32','r');a=0; %for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 
'Reading in files ...'
for i=1:500,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
'finished readin, reshaping ...'
a0 = reshape_128_128_112103(a,'bicubic'); a=0;
'reshape finished'
a_size = size(a0);
rot = zeros(1,a_size(3)); 
dis = rot;
for j = 1:a_size(3)
[px_re,py_re,px,py,cenx,ceny]=distortion_field(a0(:,:,j));
n = length(px),

for i=1:n
    a(1) = px_re(i) - cenx; a(2) = py_re(i) - ceny; a(3)=0;
    b(1) = px(i) - px_re(i) ; b(2) = py(i) - py_re(i);b(3)=0;
    r = dot(a,a);
    if r > 1,rot(j) = rot(j) + dot([0 0 1],cross(a,b))/r/n; end
    dis(j) = dis(j) + dot(b,b)/n;
end
end
figure(1), plot(dis)
figure(2), plot(rot)
median_dis = median(dis)
median_rot = median(rot)
clear a*
load C:\MATLAB6p5\work\workspace\2004_01_21\matlab_012104_2_position_slope.mat
figure(3), plot(1:500,p1456(1:500)-polyval(polyfit(1:500,p1456(1:500),1),1:500))