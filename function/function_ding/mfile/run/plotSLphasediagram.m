function plotslphasediagram(data)

a = zeros(size(data));
a(find(data == 3)) = 9;
a(find(data == 4)) = 8.5;
a(find(data == 5)) = 3;
a(find(data == 9)) = 6;
a(find(data == 6)) = 8;
close all hidden
imagesc( 2.5:0.1:3.7,3.5:0.1:6.2,a(36:63,26:38)), axis xy, axis image, colormap(gray)
%imagesc( 2.7:0.1:3.7,3.5:0.1:6.0,a(36:61,28:38)), axis xy, axis image, colormap(gray)
xlabel('Driving Amplitude 60 Hz (g)');
ylabel('Driving Amplitude 90 Hz (g)');