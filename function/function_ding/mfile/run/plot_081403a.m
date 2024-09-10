function plot_081403a

load qp_12_081103b.dat
a = qp_12_081103b ;
load sl_080103a.dat
b = sl_080103a ;

subplot(1,2,1);imagesc(0:5:85,0:5:175,max(a(:))-a'), axis xy, colormap(gray)
title('          Phase Dependence of \newline 12 Fold Quasipattern in 4:5:2 Driving ','FontSize',14)
xlabel('           Phase of 5 Mode \Phi_5 \newline A_4=4.0g A_5=6.6g,A_2=0.4g f_0=20Hz','FontSize',14)
ylabel('Phase of 2 Mode \Phi_2','FontSize',14)

subplot(1,2,2);imagesc(0.4:0.1:0.54,0:5:355,max(b(:))-b(40:54,:)'),  axis xy, colormap(gray)
title('SL-II Pattern in 6:7:2 Driving f_0=15Hz','FontSize',14);
xlabel('Dring Amplitude of 2 Mode (g)','FontSize',14)
ylabel('Phase of 2 Mode \Phi_2','FontSize',14)