qp = zeros(48,78); 
qp(1:45,1:75) = qp(1:45,1:75) + qp_1; 
qp(1:48,1:78) = qp(1:48,1:78) + qp_2; 
qp(1:48,1:75) = qp(1:48,1:75) + qp_3; 
qp(1:48,1:39) = qp(1:48,1:39) + qp_4; 
hex = zeros(48,78);
hex(1:45,1:75) = hex(1:45,1:75) + hex_1; 
hex(1:48,1:78) = hex(1:48,1:78) + hex_2; 
hex(1:48,1:75) = hex(1:48,1:75) + hex_3; 
hex(1:48,1:39) = hex(1:48,1:39) + hex_4; 
%imagesc(qp), axis xy, axis image

subplot(2,1,1), imagesc(3.5:0.1:7.8,3.0:0.1:4.8,qp(30:48,35:78)), axis xy, axis image,colormap(gray)
title('QuasiPattern Measure in 4:5 Driving ','Fontsize',18),
subplot(2,1,2), imagesc(3.5:0.1:7.8,3.0:0.1:4.8,hex(30:48,35:78)), axis xy, axis image,colormap(gray)
xlabel('Driving Amplitude of 80Hz','FontSize',18)
ylabel('Driving Amplitude of 100Hz','FontSize',18)