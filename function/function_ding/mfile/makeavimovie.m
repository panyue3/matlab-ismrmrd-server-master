m=0;n=0;
%theta=0;at=0;dif=0;delta=0;
for i = 2500:100:3600
    m=m+1; n=0;
    for j = 0:10:640
       n=n+1;a=0;b=0;
       fname = sprintf('%i_%i',i,j),
       fid=fopen(fname), 
       for L=1:39, 
           a(1:160,1:120) =fread(fid,[160,120],'uchar');
           if L==1;
               b(1:64,1:64)=a(80-32:80+31,60-32:60+31);
               b = lpfilter(b ,0.05)+1;
           end
           imagesc((a(80-32:80+31,60-32:60+31)+1)./b)
           M(L)=getframe;
       end
%      b(1:64,1:64,1:39)=a(80-32:80+31,60-32:60+31,:);
%      ifhex(m,n)=whetherhex(b);
%      ifsquare(m,n)=whethersquare(b);
       fclose(fid);
       avipath = sprintf('D:\\movie\\%s',fname)
       movie2avi(M,avipath,'FPS',8); 
    end
end
clear m, clear n, clear L,