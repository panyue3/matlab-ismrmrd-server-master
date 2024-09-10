    k10 = movie3k('0531640480010.dat');

for n = 3:9
    fname = sprintf('053164048000%li.dat',n),
    if n==1
    k01 = movie3k(fname);
    end
    if n==2
    k02 = movie3k(fname);
    end
    if n==3
    k03 = movie3k(fname);
    end
    if n==4
    k04 = movie3k(fname);
    end
    if n==5
    k05 = movie3k(fname);
    end
    if n==6 
    k06 = movie3k(fname);
    end
    if n==7 
    k07 = movie3k(fname);
    end
    if n == 8
    k08 = movie3k(fname);
    end
    if n == 9
    k09 = movie3k(fname);
    end   
    if n == 10
    k320 = movie3k(fname);
    end
end 


%for j=4:-1:1
     fname = sprintf('053064048000%li.dat',j);
     
     if j==1,
     k001 = movietotalk(fname);
     end
     if j==2,
     k002 = movietotalk(fname);
     end

     if j==3,
     k003 = movietotalk(fname);
     end
     if j==4,
     k007 = movietotalk(fname);
     end
%end

%for j=4:6
    fname =sprintf('052464048000%li.dat',j);
    
     if j==4,
     k004 = movietotalk(fname);
     end
     if j==5
     k005 = movietotalk(fname);
     end
     if j==6
     k006 = movietotalk(fname);
     end
%end
     
