m=0;n=0;k=0;
theta=0;at=0;dif=0;delta=0;
for i = 220:4:332
    m=m+1; n=0;
    for j = 0:10:350
       n=n+1;
       fname = sprintf('%i%i',i,j),
       theta = movieifsl(fname,20);
       [l1,l2]=size(theta);
%      pause(10)
%      at = (pi/3)*ones(l1,l2);
       dif = theta-pi/3;
       delta(m,n) = sqrt(sum(sum((dif.*dif)))/l1/l2);
    end
end
