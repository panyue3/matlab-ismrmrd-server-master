function plot_081303
%load sl_0_0_081203.dat
load sl_48_0_081203.dat
load sl_48_90_081203.dat
load sl_48_180_081203.dat
load sl_48_270_081203.dat

colormap(gray), 

    %subplot(2,3,1), imagesc(4.0:0.1:5.5,4.0:0.1:6.0,sl_0_0_081203(30:50,60:80)'), axis xy, axis image
    ylabel('Driving Amplitude of 105 Hz (g)'),
    title('A_2 = 0'),
    subplot(2,3,2), imagesc(4.0:0.1:5.5,4.0:0.1:6.0,sl_48_0_081203(40:55,40:60)'), axis xy, axis image
    title('A_2 = 0.42(g), \phi_2 = 0^o')
    subplot(2,3,3), imagesc(4.0:0.1:5.5,4.0:0.1:6.0,sl_48_90_081203(40:55,40:60)'), axis xy, axis image
    title('A_2 = 0.42(g), \phi_2 = 90^o')
    subplot(2,3,4), imagesc(4.0:0.1:5.5,4.0:0.1:6.0,sl_48_180_081203(40:55,40:60)'), axis xy, axis image
    title('A_2 = 0.42(g), \phi_2 = 180^o')
    xlabel('Driving Amplitude of 90 Hz (g)'),
    subplot(2,3,5), imagesc(4.0:0.1:5.5,4.0:0.1:6.0,sl_48_270_081203(40:55,40:60)'), axis xy, axis image
    title('A_2 = 0.42(g), \phi_2 = 270^o')