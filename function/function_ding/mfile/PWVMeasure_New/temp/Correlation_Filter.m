% Process the data from 2006_06_14_JH 
% First read the data in, serial number 15 to 43.

close all, clear all,
load C:\MATLAB7\work\Work_Space_Dual_CPU\2006\06_14_2006_JH\raw_data_28

imagesc(sum(a_28(:,:,10:30),3)),  axis image, colormap(gray), 
s = size(a_28);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v_0 is velocity within the aorta
% v_1 is the velocity of somewhere else.
% temp(1:s(3)) is the velocity in any position.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v_0(1:s(3)) = a_28(92,69,1:s(3)); %plot(v_0) 
v_1(1:s(3)) = a_28(69,92,1:s(3));

b = zeros(s(1),s(2));
%clock
for i= 1:s(1)
    for j=1:s(2)
        temp(1:s(3)) = a_28(i,j,1:s(3));
        m = max(abs(my_xcorr(temp',v_0' )));
        b(i,j) = m(1);
    end
    %clock,
end
%clock
subplot(1,2,2),imagesc(b), axis image, axis off, colormap(gray)
title('Maximum Cross-correlation Coefficient')
subplot(2,2,1), plot(v_0,'b*-','linewidth',2.0)
set(gca,'ytick',[])
ylabel('velocity','Fontsize',12)
title('velocity vs time at a manually selected point inside aorta')
subplot(2,2,3), plot(v_1,'b*-','linewidth',2.0)
set(gca,'ytick',[])
ylabel('velocity','Fontsize',12)
xlabel('Cine Frame number','Fontsize',12)
title('velocity vs time at a point outside aorta')
print -f1 -dpdf -r300 C:\MATLAB7\work\Work_Space_Dual_CPU\2006\06_14_2006_JH\correlation_filter

