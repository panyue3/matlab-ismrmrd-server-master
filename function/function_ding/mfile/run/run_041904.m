%plot(px2250(:,1),py2250(:,1),'*')
%exit, close all, 
%figure(1),plot(y(:,1),x(:,1),'x', yo(:,1),xo(:,1),'*'),figure(2), plot(yo(:,1),xo(:,1),'*'), hold on
%for i=0:10, plot(y(i*10+1:(i+1)*10,1),x(i*10+1:(i+1)*10,1),'rx', yo(i*10+1:(i+1)*10,1),xo(i*10+1:(i+1)*10,1),'r*'),
%    i*10:((i+1)*10+1),pause,end
%a = rand(512,512); a0 = rand(128,128);
%c = clock; c(6), abs(fftshift(fft2(a)));c = clock; c(6), abs(fftshift(fft2(a0)));abs(fftshift(fft2(a0)));abs(fftshift(fft2(a0)));c = clock; c(6),
close all, clear all
n=0;x1=0;y1=0;x2=0;y2=0;
th_1 = pi/9; th_2 = 7*pi/9;

k11 = cos(th_1); k12 = sin(th_1);
k21 = cos(th_2); k22 = sin(th_2);
k21_1 = cos(th_2+0.01); k22_1 = sin(th_2+0.01);
k1 = k11*k22 - k12*k21;
k2 = k11*k22_1 - k12*k21_1;

alpha01 = (k11 + k12)*101 ; alpha02 = (k21 + k22)*101 ; 
alpha11 = (k11 + k12)*101 ; alpha12 = (k21_1 + k22_1)*101 ; 
for i = -40*pi:2*pi:40*pi; for j= -40*pi:2*pi:20*pi; 
        x00 = ((alpha01+i)*k22 - (alpha02+j)*k12)/k1 ; 
        y00 = (k11*(alpha02+j) - k21*(alpha01+i))/k1 ;
        x01 = ((alpha11+i)*k22_1 - (alpha12+j)*k12)/k2 ; 
        y01 = (k11*(alpha12+j) - k21_1*(alpha11+i))/k2 ;
        
        if (x00-101)^2 + (y00-101)^2 < 1000
            n = n+1;
            x1(n) = x00; x2(n) = x01;
            y1(n) = y00; y2(n) = y01;        
        end
    end;end
figure(1),plot(x1,y1,'*',x2,y2,'rx')
figure(2), quiver(x1,y1,x2-x1,y2-y1,1)







