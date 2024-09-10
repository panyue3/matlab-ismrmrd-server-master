hold off
for p=2.6:0.01:4,p,
    for i=1:400, 
        x(i+1)=mod(p*x(i)*(1-x(i)),1)+rand/1000; 
    end,
    plot(p,x(200:400),'.','color',[0 0 0]),hold on,
end
