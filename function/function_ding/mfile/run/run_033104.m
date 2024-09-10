
%for i=1:500
%    an(i) = max([theta1(i) theta2(i) theta3(i)])+min([theta1(i) theta2(i) theta3(i)])-2*median([theta1(i) theta2(i) theta3(i)]);
%end
%clear i,
%'finished'
%subplot(2,2,1), plot(an),
%subplot(2,2,2), plot(rot),title('Azimuthal projection of displacement vectors')
%subplot(2,2,3), plot(p(4,1:500)), title('pattern orientation vs. time')
%subplot(2,2,4), plot(my_diff(p(4,1:500),10)),title('Instantaneous rotation speed vs. time')
v(1:80)=0;
for j =1:500
    for i=1:200
        if xp(j,i)~=0
            r = sqrt((xp(j,i)-64)^2+(yp(j,i)-66)^2);
            %th(j,i,floor(r)+1) = ang(xp(j,i)-64,yp(j,i)-66);
%            v(j,i,floor(r)+1) = dot([0 0 1],cross([xp(j,i)-cenx yp(j,i)-ceny 0],[vx(j,i) vy(j,i) 0] )/r) ;
            v(floor(r)+1) = v(floor(r)+1) + dot([0 0 1],cross([xp(j,i)-cenx yp(j,i)-ceny 0],[vx(j,i) vy(j,i) 0] )/r) ;      
        end
    end    
    %plot(th(j,:),v(j,:),'*'),axis([-pi pi -3 2]); M(j) = getframe;i=i,j=j,pause(0.1)
    pause(0.1), if mod(j,10)==0,j=j,end
end

plot(v),%plot((sum(sum(v,1),2)),'*')



%x=1.450:0.002:1.458;
%subplot(2,2,1), plot(x,s(:,1),'s-'),axis([1.450 1.460 -0.75 -0.4])
%subplot(2,2,2), plot(x,median_rot,'d-',x,mean_rot,'h-'),axis([1.450 1.460 -0.0076 -0.0062])
%subplot(2,2,3), plot(x,median_dis,'o-',x,mean_dis,'*-'),axis([1.450 1.460 2 3.2])
%subplot(2,2,4), plot(my_diff(p(4,1:500),10)),title('Instantaneous rotation speed vs. time')
%subplot(4,4,1), plot(p2230), axis tight
%subplot(4,4,2), plot(p2240), axis tight
%subplot(4,4,3), plot(p2250), axis tight
%subplot(4,4,4), plot(p2260), axis tight
%subplot(4,4,5), plot(p2270), axis tight
%subplot(4,4,6), plot(p2280), axis tight
%subplot(4,4,7), plot(p2290), axis tight
%subplot(4,4,8), plot(p2300), axis tight
%subplot(4,4,9), plot(p2310), axis tight
%subplot(4,4,10), plot(p2320), axis tight
%subplot(4,4,11), plot(p2330), axis tight
%subplot(4,4,12), plot(p2340), axis tight
%subplot(4,4,13), plot(p2350), axis tight
%subplot(4,4,14), plot(p2360), axis tight
%subplot(4,4,15), plot(p2370), axis tight
