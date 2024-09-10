% test Fourier decomposition of periodic delta function

x = pi/1024:pi/512:4*pi;
y1 = zeros(size(x));
y2= y1; y3=y2; y4 = y3 ;
for i=1:20, 
    y1 = y1 + cos(x*i); 
    y2 = y2 + (0)^(mod(i,2))*cos(x*i);
    y3 = y3 + (0)^(mod(i+1,2))*cos(x*i*2);
    y4 = y4 + (-1)^(mod(i,2)+1)*cos(i*x);
end, 
figure(1)
subplot(2,2,1), plot(x,y1);
subplot(2,2,2), plot(x,y2);
subplot(2,2,3), plot(x,y3);
subplot(2,2,4), plot(x,y4);

