addpath 041404


i=2238;
j=round(i*2.322);
fname = sprintf('%d_%d_90_0_0',i,j),
[ b00,y00] =  background_mov(fname,12,12,'bicubic');


m = ones(1:360,1:60);for i=1:60, m(1:360,i)=i;end

chirality = zeros(301*7,20);
[x,y] = meshgrid(1:128,1:128);
mask = (x-67).^2 + (y-67).^2 < 57*57;
%c = clock; c(5:6),
for k = 0:9,
for i=2238:2:2276,
    j = round(2.322*i);
    fname = sprintf('%d_%d_90_0_%d',i,j,k),
    fid = fopen(fname,'r');
    a00=fread(fid,[160,120],'uchar'); 
    counter=0; a0 = 0;
    while length(a00(:))==19200
        counter = counter + 1;
        %imagesc(a0), pause(0.1)
        a0 = a0 + a00;
        a00=fread(fid,[160,120],'uchar'); 
    end
    fclose(fid);
    a = reshape_128_img( a0,b00,y00 );
    % Get rid of the background bad point,
    a(122:128,102:108)=0; a = a.* mask;
    [y0,x0] = find_insert_rotation_center(fname);
    %a_rt = xy2rt(a,y0,x0,1:60,0:pi/180:2*pi-0.001);
    %figure(2),imagesc(a_rt)
    %figure(1), imagesc(a)
    
    
     fid = fopen(fname,'r');
    a00=fread(fid,[160,120],'uchar'); 
    counter=0; a0 = 0;
    while length(a00(:))==19200
        counter = counter + 1;
        a = reshape_128_img( a00,b00,y00 );
        a(122:128,102:108)=0; a = a.* mask;
        a_rt = xy2rt(a,y0,x0,1:60,0:pi/180:2*pi-0.001);
        a_rt_i = a_rt(360:-1:1,:);
        chirality(counter+(k)*301,(i-2238)/2+1) = 1- max(max(my_corr2(a_rt.*m,a_rt_i.*m)));
         a00=fread(fid,[160,120],'uchar'); 
    end
    fclose(fid);
  
    %break
end,
end
chirality_041404 = chirality;
c = clock,
save  workspace_compaq\2004_04_1404\matlab_041404.mat

