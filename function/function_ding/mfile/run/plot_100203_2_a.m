load C:\MATLAB6p5\work\workspace\10_01_03\093003a.mat
n4=3.5:0.1:5.0; n5 = 4.0:0.1:6.5;
colormap(gray);
qp3 = qp_3(35:50,40:65)*64;    qp4 = qp_4(35:50,40:65)*64;
hex3 = hex_3(35:50,40:65)*64;  hex4 = hex_4(35:50,40:65)*64;

%imagesc(n5,n4,qp5)
subplot(2,2,1), image(n5,n4,qp3), axis xy, colorbar
title('QuasiPattern in 4:5 Driving  f_0=20Hz','FontSize',14)
ylabel('Driving Anplitude of 80Hz (g)','FontSize',14)
subplot(2,2,2), image(n5,n4,qp4), axis xy, colorbar
title('QuasiPattern in 4:5:2 Driving  f_0=20Hz','FontSize',14)
subplot(2,2,3), image(n5,n4,hex3), axis xy, colorbar
title('HexPattern in 4:5 Driving  f_0=20Hz','FontSize',14)
xlabel('Driving Anplitude of 100Hz (g)','FontSize',14)
subplot(2,2,4), image(n5,n4,hex4), axis xy, colorbar
title('HexPattern in 4:5:2l Driving  f_0=20Hz','FontSize',14)
