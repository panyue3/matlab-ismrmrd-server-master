figure(1), hold on
for i=49.5:0.05:50.5
    r = i;
    for j=50:-1:1
        r = r+floor(3*rand-1),
        plot(r,j,'.')
    end
    pause(1)
end


