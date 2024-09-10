%addpath 111203_1
%rmpath 111103_2
%rmpath 111103_3
addpath 112003_1

[p_1,ang_1,qp_1,qp_ang_1,sl_1,sl_ang_1,hex_1,hex_ang_1]=find_ang_corr(0,0,32,32,3000,5000,500,500,16,16,18);
%[p_2,ang_2,qp_2,qp_ang_2,sl_2,sl_ang_2,hex_2,hex_ang_2]=find_ang_corr(20,20,32,32,3000,5000,500,500,16,16,18);
%[p_3,ang_3,qp_3,qp_ang_3,sl_3,sl_ang_3,hex_3,hex_ang_3]=find_ang_corr(40,40,32,32,3000,5000,500,500,16,16,18);
%[p_4,ang_4,qp_4,qp_ang_4,sl_4,sl_ang_4,hex_4,hex_ang_4]=find_ang_corr(60,60,32,32,3000,5000,500,500,16,16,18);
%[p_5,ang_5,qp_5,qp_ang_5,sl_5,sl_ang_5,hex_5,hex_ang_5]=find_ang_corr(60,60,32,32,3000,5000,500,500,16,16,18);

%save matlab_111203_1
%rmpath 111203_1
%clear all

%addpath 111203_2
%[p_2,ang_2,qp_2,qp_ang_2,sl_2,sl_ang_2,hex_2,hex_ang_2]=find_ang_corr(80,80,32,32,3000,4800,760,780,16,16,18);
%rmpath 111203_2
%addpath 111203_3 
%[p_3,ang_3,qp_3,qp_ang_3,sl_3,sl_ang_3,hex_3,hex_ang_3]=find_ang_corr(80,80,32,32,4600,4800,400,750,16,16,18);
%rmpath 111203_3
%addpath 110703
%[p_4,ang_4,qp_4,qp_ang_4,sl_4,sl_ang_4,hex_4,hex_ang_4]=find_ang_corr(80,80,32,32,3000,4800,350,390,16,16,18);
%rmpath 110703
%save matlab_patch_103103 
%addpath 111103_2

%[p_3,ang_3,qp_3,qp_ang_3,sl_3,sl_ang_3,hex_3,hex_ang_3]=find_ang_corr(80,80,32,32,3000,4800,760,780,16,16,18);
%addpath 111103_3
%[p_4,ang_4,qp_4,qp_ang_4,sl_4,sl_ang_4,hex_4,hex_ang_4]=find_ang_corr(80,80,32,32,4600,4800,400,750,16,16,18);


% save matlab_111103_2_3
%subplot(2,1,1), imagesc(3.5:0.1:8.0,3.0:0.1:5.0,qp_1(30:50,35:80)), axis xy, axis image,colormap(gray)
%title('QuasiPattern Measure in 4:5:2 Driving A_2=0.80g','Fontsize',18),
%subplot(2,1,2), imagesc(3.5:0.1:8.0,3.0:0.1:5.0,hex_1(30:50,35:80)), axis xy, axis image,colormap(gray)
%xlabel('Driving Amplitude of 80Hz','FontSize',18)
%ylabel('Driving Amplitude of 100Hz','FontSize',18)