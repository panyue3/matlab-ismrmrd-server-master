%addpath 112003_2
%addpath 112503
%addpath 112503_1
%addpath 112503_2
%addpath 112503_3
%addpath 112803

[p_1,ang_1,qp_1,qp_ang_1,sl_1,sl_ang_1,hex_1,hex_ang_1]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,500,500,16,16,18);
[p_2,ang_2,qp_2,qp_ang_2,sl_2,sl_ang_2,hex_2,hex_ang_2]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,550,550,16,16,18);
[p_3,ang_3,qp_3,qp_ang_3,sl_3,sl_ang_3,hex_3,hex_ang_3]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,600,600,16,16,18);
[p_4,ang_4,qp_4,qp_ang_4,sl_4,sl_ang_4,hex_4,hex_ang_4]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,650,650,16,16,18);
[p_5,ang_5,qp_5,qp_ang_5,sl_5,sl_ang_5,hex_5,hex_ang_5]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,700,700,16,16,18);
[p_6,ang_6,qp_6,qp_ang_6,sl_6,sl_ang_6,hex_6,hex_ang_6]=find_ang_corr_a2_a4(0,90,32,32,3000,5000,750,750,16,16,18);



subplot(2,1,1), imagesc(0:0.05:.9,3.0:0.1:5.0,qp_4(:,30:50)'), axis xy, colormap(gray)
title('QuasiPattern Measure in 4:5:2 Driving A_5 = 6.5g (Average over 8 maximum) ','Fontsize',18),
subplot(2,1,2), imagesc(0:0.05:.9,3.0:0.1:5.0,hex_4(:,30:50)'), axis xy,colormap(gray)
xlabel('Driving Amplitude of 40Hz','FontSize',18)
ylabel('Driving Amplitude of 80Hz','FontSize',18)
