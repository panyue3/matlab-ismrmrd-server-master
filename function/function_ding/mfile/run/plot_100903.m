colormap(gray)
subplot(2,2,1), imshow(5.5:0.1:7.5,4.0:0.1:5.5,sl_1(40:55,55:75)),axis xy,colorbar('vert');
axis on
% xlabel('Driving of 120Hz, 6 Mode (g)','Fontsize',14)
ylabel('Driving of 105Hz, 7 Mode (g)','Fontsize',14)
title('Measure of SL-1 Pattern','Fontsize',14)

subplot(2,2,2), imagesc(5.5:0.1:7.5,4.0:0.1:5.5,ang_sl_1(40:55,55:75)),axis xy,colorbar('vert');
% xlabel('Driving of 120Hz, 6 Mode (g)','Fontsize',14)
%ylabel('Driving of 105Hz, 7 Mode (g)','Fontsize',14)
title('Angle of SL-1 Pattern','Fontsize',14)

subplot(2,2,3), imagesc(5.5:0.1:7.5,4.0:0.1:5.5,hex_1(40:55,55:75)),axis xy,colorbar('vert');
xlabel('Driving of 90Hz, 6 Mode (g)','Fontsize',14)
ylabel('Driving of 105Hz, 7 Mode (g)','Fontsize',14)
title('Measure of Hex Pattern','Fontsize',14)

subplot(2,2,4), imagesc(5.5:0.1:7.5,4.0:0.1:5.5,hex_ang_1(40:55,55:75)),axis xy,colorbar('vert');
%xlabel('Driving of 120Hz, 6 Mode (g)','Fontsize',14)
xlabel('Note: data from 100703 6:7:2 driving \Phi_7=35^0, \Phi_2=70^0; plot from mfile plot_100903.m, \newline the workspace is from workspace/100903/...','Fontsize',10)
title('Angle Hex Pattern','Fontsize',14)
