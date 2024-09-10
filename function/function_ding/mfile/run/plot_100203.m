load C:\MATLAB6p5\work\workspace\10_01_03\100103.mat
n4=3.0:0.1:4.5; n5 = 4.0:0.1:7.5;
colormap(gray);
qp5 = qp_5(30:45,40:75)*64;    qp7 = qp_7(30:45,40:75)*64;
hex5 = hex_5(30:45,40:75)*64;  hex7 = hex_7(30:45,40:75)*64;

%imagesc(n5,n4,qp5)
subplot(2,2,1), image(n5,n4,qp5), axis xy, colorbar
title('QuasiPattern in 4:5:2 Driving  f_0=20Hz','FontSize',14)
ylabel('Driving Anplitude of 80Hz (g)','FontSize',14)
subplot(2,2,2), image(n5,n4,qp7), axis xy, colorbar
title('QuasiPattern in 4:5 Driving  f_0=20Hz','FontSize',14)
subplot(2,2,3), image(n5,n4,hex5), axis xy, colorbar
title('HexPattern in 4:5:2 Driving  f_0=20Hz','FontSize',14)
xlabel('Driving Anplitude of 100Hz (g)','FontSize',14)
subplot(2,2,4), image(n5,n4,hex7), axis xy, colorbar
title('HexPattern in 4:5 Driving  f_0=20Hz','FontSize',14)
