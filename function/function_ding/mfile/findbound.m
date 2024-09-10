temp =lpfilter(hex,0.8) <0.20;
for i=1:36
    j=0;do=1;
    while j<14&do,
        j=j+1;
        if temp(j,i)==1&temp(j+1,i)==0
           onsetbound(i)=j;do=0;
        end   
        if j==14&do, bound(i)=15; end
    end
end 

clear i, clear j, clear do, clear temp,
