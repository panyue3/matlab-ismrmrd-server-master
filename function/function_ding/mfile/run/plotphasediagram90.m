addpath C:\MATLAB6p5p1\work\data_allemande
close all 
load phase90new.dat ; phase0 = phase90new;
 load bound060303.dat ; bound2 = bound060303;
 load upperbound90.dat ; bound3 = upperbound90;
 bound = 0;
 phase0(42:46,:)=6;
 for i=1:46     
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

for i=1:275,
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

figure(1),imagesc(0:0.1:5.4,2.0:0.01:2.74,bound(201:275,:)),axis xy,% figure(2), imagesc(bound),bound =0;

for j=1:547,
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

figure(1),imagesc(5.20:0.01:5.47,0:0.1:2.0,bound(1:21,520:547)), axis xy,

i0=46; markersize=3;

for i=1:i0,for j=1:65, plot(0.1*(j-1),0.1*(i-1),'.','color',[1 1 1],'markersize',markersize),end,end
for i=1:11, for j=256:275, plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),end,end
for i=12:55, a=round(251-1.14*(i-12));b=round(275-1.14*(i-12));
    for j = a:b,
        plot(0.1*(i-1),0.01*j,'.','color',[1 1 1],'markersize',markersize-1),
    end
end
for i=1:21, for j=528:547, plot(0.01*(j),0.1*(i-1),'.','color',[1 1 1],'markersize',markersize-1),end,end

xlabel('Driving Amplitude of 90 Hz (g)','Fontsize',20),
ylabel('Driving Amplitude of 60 Hz (g)','Fontsize',20),
title('\Phi=135^o','Fontsize',20),

hold off,

clear i,clear i0, clear phase, clear j, clear markersize; clear bound2, clear bound3 , clear bound;clear phase0, clear phase,

%for i=1:i0,for j=1:65, if phase(i,j)==0,plot(0.1*(i-1),0.1*(j-1),'','color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==0.5,plot(0.1*(i-1),0.1*(j-1),'o','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==1,plot(0.1*(i-1),0.1*(j-1),'s','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==3,plot(0.1*(i-1),0.1*(j-1),'h','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==4,plot(0.1*(i-1),0.1*(j-1),'*','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==5,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==6,plot(0.1*(i-1),0.1*(j-1),'v','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==7,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==8,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:65, if phase(i,j)==9,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end