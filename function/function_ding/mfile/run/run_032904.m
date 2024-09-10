addpath 032404
fname = '2310_5364_90_0_4';
[b0,y0] =  background_mov(fname,16,16,'bilinear');
fid = fopen(fname,'r');

% Skip some frames
%for i=1:3, a00=fread(fid,[160,120],'uchar');  end
    
a00=fread(fid,[160,120],'uchar');  
a00 = double(a00);
j = 0; rot=0;dis=0;
xp = zeros(500,200);yp=xp; vx=xp;vy=xp;
while prod(size(a00))==19200,     
    %a00 = a00./b0;
    a0 = reshape_128_img(a00,b0,y0); %figure(1), imagesc(a0)
    j = j+1,
    [px_re,py_re,px,py,cenx,ceny,theta1(j),theta2(j),theta3(j)]=distortion_field(a0);
    n = length(px), %figure(2),plot(px,py,'*',px_re,py_re,'d'), pause
    xp(j,1:n) = px_re;  yp(j,1:n) = py_re;  vx(j,1:n)= px-px_re;    vy(j,1:n)=py-py_re;
    rot(j)=0;dis(j)=0 ;   
    for i=1:n
    a(1) = px_re(i) - cenx; a(2) = py_re(i) - ceny; a(3)=0;
    b(1) = px(i) - px_re(i) ; b(2) = py(i) - py_re(i);b(3)=0;
    r = dot(a,a);
    if r > 1,rot(j) = rot(j) + dot([0 0 1],cross(a,b))/r/n; end
    dis(j) = dis(j) + dot(b,b)/n;
    end
    if j >499 break, end
    a00=fread(fid,[160,120],'uchar');  
end

median_dis = median(dis)
median_rot = median(rot)
clear a*, clear b*
save matlab_032404_2310_1_500



fname = '2320_5387_90_0_4';
[b0,y0] =  background_mov(fname,16,16,'bilinear');
fid = fopen(fname,'r');

% Skip some frames
%for i=1:3, a00=fread(fid,[160,120],'uchar');  end
    
a00=fread(fid,[160,120],'uchar');  
a00 = double(a00);
j = 0; rot=0;dis=0;
xp = zeros(500,200);yp=xp; vx=xp;vy=xp;
while prod(size(a00))==19200,     
    %a00 = a00./b0;
    a0 = reshape_128_img(a00,b0,y0); %figure(1), imagesc(a0)
    j = j+1,
    [px_re,py_re,px,py,cenx,ceny,theta1(j),theta2(j),theta3(j)]=distortion_field(a0);
    n = length(px), %figure(2),plot(px,py,'*',px_re,py_re,'d'), pause
    xp(j,1:n) = px_re;  yp(j,1:n) = py_re;  vx(j,1:n)= px-px_re;    vy(j,1:n)=py-py_re;
    rot(j)=0;dis(j)=0 ;   
    for i=1:n
    a(1) = px_re(i) - cenx; a(2) = py_re(i) - ceny; a(3)=0;
    b(1) = px(i) - px_re(i) ; b(2) = py(i) - py_re(i);b(3)=0;
    r = dot(a,a);
    if r > 1,rot(j) = rot(j) + dot([0 0 1],cross(a,b))/r/n; end
    dis(j) = dis(j) + dot(b,b)/n;
    end
    if j >499 break, end
    a00=fread(fid,[160,120],'uchar');  
end

median_dis = median(dis)
median_rot = median(rot)
clear a*, clear b*
save matlab_032404_2320_1_500

