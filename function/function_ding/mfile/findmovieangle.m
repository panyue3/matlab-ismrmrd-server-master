% Hi, remember to choose the proper K00!!!%
m=0;n=0;k=0;
%theta=0;at=0;dif=0;delta=0;
for i = 660:4:684
    m=m+1; n=0; 
    for j = 0:10:355
       n=n+1; 
       fname = sprintf('%i%i',i,j),
       [onset(m,n),hex(m,n)] = checkonsetcircle(fname);
%      hex(m,n) = checkifcircle(fname);
%      ratio(m,n) = movieratio(fname,15); 
%       [d(m,n),k(m,n),ratio(m,n)] = movieang(fname,6,15);
%      [l1,l2]=size(theta);
%      pause(10)
%      at = (pi/3)*ones(l1,l2);
%      dif = theta-at;
%      delta(m,n) = sqrt(sum(sum((dif.*dif)))/l1/l2);
    end
end

clear m, clear n, clear theta; clear at; clear dif; clear delta; 
clear i, clear j; clear fname; 
