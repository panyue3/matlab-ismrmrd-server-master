m=0;n=0;k=0;
theta=0;at=0;dif=0;delta=0;
for i = 220:4:332
    m=m+1; n=0;
    for j = 0:10:350
       n=n+1;
       fname = sprintf('%i%i',i,j),
       theta(m,n) = checkslratio(fname,11,16);
    end
end
