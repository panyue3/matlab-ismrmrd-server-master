close all hidden
x=5.5:0.1:7.5;y=4.0:0.1:5.5;
figure(1)
%colormap(gray)
subplot(2,2,1), image(x,y,sl_1(40:55,55:75)*64),axis xy, axis image,colorbar
title('SuperLattice Measure in 6:7:2 Driving','Fontsize',12)
ylabel('Driving Amplitude of 105Hz','Fontsize',12)
subplot(2,2,2), image(x,y,sl_2(40:55,55:75)*64),axis xy, axis image,colorbar
title('SuperLattice Measure in 6:7 Driving','Fontsize',12)
subplot(2,2,3), imagesc(x,y,sl_ang_1(40:55,55:75)),axis xy, axis image,colorbar
title('Position (Angle) of the Peak in 6:7:2 Driving','Fontsize',12)
xlabel('Driving Amplitude of 90Hz','Fontsize',12)
ylabel('Driving Amplitude of 105Hz','Fontsize',12)
subplot(2,2,4), imagesc(x,y,sl_ang_2(40:55,55:75)),axis xy, axis image,colorbar
title('Position (Angle) of the Peak in 6:7 Driving','Fontsize',12)
xlabel('Driving Amplitude of 90Hz','Fontsize',12)

figure(2)
%colormap(gray)
subplot(2,2,1), image(x,y,p_1(40:55,55:75)*64),axis xy, axis image,colorbar
title('Peak(10^o ~ 50^o) Measure in 6:7: Driving','Fontsize',12)
ylabel('Driving Amplitude of 105Hz','Fontsize',12)
subplot(2,2,2), image(x,y,p_2(40:55,55:75)*64),axis xy, axis image,colorbar
title('Peak(10^o ~ 50^o) Measure in 6:7 Driving','Fontsize',12)
subplot(2,2,3), imagesc(x,y,ang_1(40:55,55:75)),axis xy, axis image,colorbar
title('Peak Position (Angle) of the Peak in 6:7:2 Driving','Fontsize',12)
xlabel('Driving Amplitude of 90Hz','Fontsize',12)
ylabel('Driving Amplitude of 105Hz','Fontsize',12)
subplot(2,2,4), imagesc(x,y,ang_2(40:55,55:75)),axis xy, axis image,colorbar
title('Peak Position (Angle) of the Peak in 6:7 Driving','Fontsize',12)
xlabel('Driving Amplitude of 90Hz','Fontsize',12)

%subplot(2,1,1), plot(sl_1)
%title('SuperLattice Measure in 6:7 Driving A_6=4.0g A_7=7.4g (data from 081203b)','Fontsize',14)
%ylabel('SL Measure (Auto-correlation)','Fontsize',14)
%subplot(2,1,2), plot(sl_ang_1)
%xlabel('Phase \Phi_7','Fontsize',14)
%ylabel('Angle (in Degree)','Fontsize',14)
%title('The Position of the Peak (Angle in Degree)','Fontsize',14)

%figure(2)
%subplot(2,1,1), plot(p_1)
%title('Peak Measure(10^o to 50^o From the Primary Peak) in 6:7 Driving A_6=4.0g A_7=7.4g \newline (data from 081203b)','Fontsize',14)
%ylabel('Peak Measure (Auto-correlation)','Fontsize',14)
%subplot(2,1,2), plot(ang_1)
%xlabel('Phase \Phi_7','Fontsize',14)
%ylabel('Angle (in Degree)','Fontsize',14)
