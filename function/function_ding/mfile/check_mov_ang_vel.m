close all, %clear all
%rmpath 010704_2
%addpath 010704_2
%addpath 010804
%rmpath 010504_1
n=0;
for i=1484:4:1520,j=round(i*2.322);
    n=n+1;
    fname=sprintf('%d_%d_90_0_4',i,j),
%    fid = fopen(fname,'r'),for i=1:3, a = fread(fid,[160,120],'uchar');pause(0.2), imagesc(a'),axis xy, axis image,end;fclose(fid)
    %v = find_angular_velocity(fname,12); hist(v), pause
    [p1484_04(n,1:101),s1484_04(n,1:2)] = find_mov_peak_ang(fname,12);
    %if n==1;[p1455(1:5001),s1455(1:2)] = find_mov_peak_ang(fname,12);
    %else [p1456(1:5001),s1456(1:2)] = find_mov_peak_ang(fname,12);
    %end
    %[p,s] = find_mov_peak_ang(fname,12);
       
%    close all hidden
%    pause
end
%n=2;
%for i=1446:1:1475,j=round(i*2.322);
%    n=n+1;
%    fname=sprintf('%d_%d_90_0_32',i,j),
    %fid = fopen(fname,'r'),for i=1:3, a = fread(fid,[160,120],'uchar');pause(0.2), imagesc(a),end;fclose(fid)
%    [p(n,1:301),s(n,1:2)] = find_mov_peak_ang(fname,12);
        
    close all hidden
    
    %end

%figure(1), plot(p(1,:))
%figure(2), plot(p(2,:))
%figure(3), plot(p(3,:))
%figure(4), plot(p(4,:))
%figure(5), plot(p(5,:)) 


clear n, clear i, clear j, clear fname, clear a, clear fid,