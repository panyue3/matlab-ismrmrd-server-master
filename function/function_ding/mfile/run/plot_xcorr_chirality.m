i=0;
for a=0.01:0.01:1;
    i=i+1;
    y0 = zeros(1,200); y1 = y0;
    y0(50:150) = 1-a:a/50:1+a;
    y1(50:150) = 1+a:-a/50:1-a;
    y0 = y0 - mean(y0(:));
    y1 = y1 - mean(y1(:));
    corr = my_xcorr(y0,y1);
    figure(1);plot(corr);hold on ;
    max_corr(i) = max(corr);
end
figure(2), plot(max_corr)
hold off

