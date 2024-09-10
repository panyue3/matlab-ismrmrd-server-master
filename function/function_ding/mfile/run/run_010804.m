%close all hidden
%n=1,
%for i=1:20
%a(i,1:500) = (abs(diff(p(i,:)))) ;
%b=sum(a(i,1:500)<0.5),
%size(p(i,1+find(a(i,1:500)<0.5)))%
%c(n:n+b-1)=p(i,1+find(a(i,1:500)<0.5))';
%n = n+b;
%end
%hist(mod(c,360),360)
%figure(1)
%for i=1:24,
%    subplot(4,6,i), if i>2,plot(p(i,1:301));else, plot(p(i,:)),end ; axis tight
    %legend(sprintf('%d',s(i,1)))
    %end

%figure(2)
%for i=25:32,
%    subplot(4,6,i-24), plot(p(i,1:301)), axis tight
    %legend(sprintf('%d',s(i,1)))
    %end
    slope = 0; p=p1455;
    %for j=1:5
    N=25,
for i=N+1:5001-N-1;
    p0 = p(1,i-N:i+N);
    s0 = polyfit(1:2*N+1,p0,1);
    slope(i,1)=abs(s0(1)); s0 =0;
end
%end
%figure(1), plot(p(2,:)); figure(2), plot(slope)
 %for i=1:4
 %    subplot(2,2,i), plot(mod(p(i+1,101:2900),360),slope(101:2900,i+1),'*')
 %end
    
  %figure(2)  
    subplot(2,3,4),    plot(mod(p(N+1:4975),360),slope(N+1:4975),'*')
    title('A_2=1.455')