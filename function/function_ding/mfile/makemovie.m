m=0;n=0;
%theta=0;at=0;dif=0;delta=0;
for i = 2500:100:3600
    m=m+1; n=0;
    for j = 0:10:640
       n=n+1;a=0;b=0;
       fname = sprintf('%i_%imov',i,j),
       fid=fopen(fname), 
       for L=1:39, 
           a(1:160,1:120,L) =fread(fid,[160,120],'uchar');
           imagesc(a(80-32:80+31,60-32:60+31,L))
           M(L)=getframe;
       end
%      b(1:64,1:64,1:39)=a(80-32:80+31,60-32:60+31,:);
%      ifhex(m,n)=whetherhex(b);
%      ifsquare(m,n)=whethersquare(b);
       fclose(fid);
       movie2avi(M,'D:\movie\'fname,'FPS',8); 
    end
end
