m=0;n=0;
%theta=0;at=0;dif=0;delta=0;
for i = 2500:100:3600
    m=m+1; n=0;
    for j =  0:10:640
       n=n+1;a=0;b=0;
       fname = sprintf('%i_%imov',i,j),
       fid=fopen(fname), a =fread(fid,[160,120],'uchar'); fclose(fid);
       b=a(80-32:80+31,60-32:60+31);
       b=b./lpfilter(b,0.06); 
       b=lpfilter(b,0.6); b=hpfilter(b,0.1);
       [ifhexnew(m,n),ifsquarenew(m,n)]=whetherhexsquarenew(b);
    end
end


clear i, clear a*, clear b, clear fid, clear j, clear m, clear n, clear fname 

