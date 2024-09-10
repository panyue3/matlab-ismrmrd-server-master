close all hidden
figure(1)
for i=1:24,
    subplot(4,6,i), if i>2,plot(p(i,1:301));else, plot(p(i,:)),end ; axis tight
    %legend(sprintf('%d',s(i,1)))
end

figure(2)
for i=25:32,
    subplot(4,6,i-24), plot(p(i,1:301)), axis tight
    %legend(sprintf('%d',s(i,1)))
end
%for i=1:25,
%    subplot(5,5,i), plot(p(i,:)), axis tight,
%end
%figure(2)
%for i=26:50,
%    subplot(5,5,i-25), plot(p(i,:)), axis tight,
%end
%figure(3)
%for i=51:75,
%    subplot(5,5,i-50), plot(p(i,:)), axis tight,
%end
%figure(4)
%for i=76:100,
%    subplot(5,5,i-75), plot(p(i,:)), axis tight,
%end


