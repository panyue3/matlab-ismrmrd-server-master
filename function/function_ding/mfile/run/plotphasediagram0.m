close all, addpath C:\MATLAB6p5p1\work\data_allemande
 load phase0new.dat,   phase0 = phase0new;
 load bound052203.dat, bound2 = bound052203;
 load ubound0new.dat, bound3 = ubound0new;

bound = 0;
 for i=1:51     
    for j=1:65
        if phase0(i,j)==0, 
            phase(i,j)=6;
        elseif phase0(i,j)==0.5, 
            phase(i,j)=5.5;
        elseif phase0(i,j)==1, 
            phase(i,j)=5;
        elseif phase0(i,j)==2, 
            phase(i,j)=4;    
        elseif phase0(i,j)==3, 
            phase(i,j)=3;
        elseif phase0(i,j)==4, 
            phase(i,j)=2;
        elseif phase0(i,j)==5, 
            phase(i,j)=5;
        elseif phase0(i,j)==6, 
            phase(i,j)=0;
        elseif phase0(i,j)==7, 
            phase(i,j)=5;
        elseif phase0(i,j)==8, 
            phase(i,j)=5;
        elseif phase0(i,j)==9, 
            phase(i,j)=5;    
        end    
    end
end

hold off,figure(1); imagesc(0:0.1:6.4,0:0.1:4.5,phase(1:46,:)), colormap(gray), axis xy, hold on, 

for i = 1:280
    for j=1:54
        if bound2(i,j)==0
            bound(i,j)=6;
        elseif bound2(i,j)==0.5, 
            bound(i,j)=5.5;
        elseif bound2(i,j)==1, 
            bound(i,j)=5;
        elseif bound2(i,j)==2, 
            bound(i,j)=4;    
        elseif bound2(i,j)==3, 
            bound(i,j)=3;
        elseif bound2(i,j)==4, 
            bound(i,j)=2;
        end
    end
end

figure(1),imagesc(0:0.1:5.4,2.0:0.01:2.74,bound(201:275,:)),axis xy,

for j=1:550,
    for i=1:24
        if bound3(i,j)==0
            bound(i,j)=6;
        elseif bound3(i,j)==0.5, 
            bound(i,j)=5.5;
        elseif bound3(i,j)==1, 
            bound(i,j)=5;
        elseif bound3(i,j)==2, 
            bound(i,j)=4;    
        elseif bound3(i,j)==3, 
            bound(i,j)=3;
        elseif bound3(i,j)==4, 
            bound(i,j)=2;
        end
    end
end
figure(1),imagesc(5.20:0.01:5.50,0:0.1:2.0,bound(1:21,520:550)), axis xy,
 
i0=45; markersize=3;

for i=1:i0,for j=1:65, plot(0.1*(j-1),0.1*(i-1),'.','color',[1 1 1],'markersize',markersize),end,end
for i=1:10, for j=254:280, plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),end,end
for i=11:26, for j=247:270, plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),end,end 
for i=27:41, for j=230:259, plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),end,end 
for i=42:54, for j=210:248, plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),end,end 
for i=1:21, for j=525:550, plot(0.01*(j),0.1*(i-1),'.','color',[1 1 1],'markersize',markersize-1),end,end

xlabel('Driving Amplitude of 90 Hz (g)','Fontsize',20),
ylabel('Driving Amplitude of 60 Hz (g)','Fontsize',20),
title('\Phi=45^o','Fontsize',20),


hold off,

clear i,clear i0, clear phase, clear j, clear markersize, clear bound2, clear bound3 , clear bound;clear phase0, clear phase,clear a, clear b,clear all