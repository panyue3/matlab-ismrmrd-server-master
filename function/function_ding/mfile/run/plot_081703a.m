load  qp_081403b.dat; load qp_081203a.dat; 
a = qp_081403b; b = qp_081203a; 
subplot(2,1,1), plot(a), axis xy
title('Driving Phase Dependence of QuasiPattern','Fontsize',15)
subplot(2,1,2), plot(b(3,:)), axis xy
xlabel('Phase \Phi_5','Fontsize',15)
ylabel('                            Relative QP Measure','Fontsize',15)


%load sl_abs_081303b_71.dat ;load sl_abs_081303b_72.dat; load sl_abs_081303b_73.dat; load sl_abs_081203c.dat
%a1 = sl_abs_081303b_71; a2 = sl_abs_081303b_72; a3 = sl_abs_081303b_73;
%a4 = sl_abs_081203c;
%subplot(1,4,1), imagesc(0:5:115,0:10:170,lpfilter(max(a1(:))-a1',0.4)), axis xy,axis image, colormap(gray)
%ylabel('  Phase \Phi_2','Fontsize',15)
%title('                                                                                           Driving phase dependence in 6:7:2 Driving ; f_0=15 Hz ; A_6 = 4.0 ; A_7 = 7.1:0.1:7.4 ; A_2 = 0.4','Fontsize',15)
%subplot(1,4,2), imagesc(0:5:115,0:10:170,lpfilter(max(a2(:))-a2',0.4)), axis xy,axis image, colormap(gray)
%xlabel('                             Phase \Phi_7','Fontsize',15)
%subplot(1,4,3), imagesc(0:5:115,0:10:170,lpfilter(max(a3(:))-a3',0.4)), axis xy,axis image, colormap(gray)

%subplot(1,4,4), imagesc(0:5:115,0:10:170,lpfilter(max(a4(:))-a4',0.4)), axis xy,axis image, colormap(gray)

%a=(lpfilter(qp_12_081103b,0.5));
%imagesc(max(a(:))-a), colormap(gray)
%b=((qp_12_081103b));
%subplot(1,2,1) , imagesc(0:5:85,0:5:175,max(a(:))-a'), colormap(gray), axis xy
%xlabel('Phase \Phi_5','Fontsize',15),
%ylabel('Phase \Phi_4','Fontsize',15),
%title('                                                 Driving Phase dependence of QuasiPattern in 4:5 Driving','Fontsize',15),
%subplot(1,2,2) , imagesc(0:5:85,0:5:175,max(b(:))-b'), colormap(gray), axis xy
%xlabel('Phase \Phi_5','Fontsize',15),

%a = qp_abs_12_080903;
%subplot(1,2,1),imagesc(3.4:0.1:5.0,4.0:2.5/41:6.49,max(a(:))-a(34:50,:)'), axis xy, colormap(gray)
%xlabel('Driving Amplitude of 80 Hz','Fontsize',15)
%ylabel('Driving Amplitude of 100 Hz','Fontsize',15)
%title('                                                        The Quasipattern in 4:5 Driving, f_0=20Hz','Fontsize',15)
%subplot(1,2,2),imagesc(3.4:0.1:5.0,4.0:2.5/41:6.49,lpfilter(sqrt(max(a(:)))-a(34:50,:)',0.5)),axis xy
