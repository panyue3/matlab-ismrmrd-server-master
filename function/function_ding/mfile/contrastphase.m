% phase0 = phase90new;
% bound2 = bound060303;
% bound3 = upperbound90;

 load phase0new.dat,   phase0 = phase0new;
 load bound052203.dat, bound2 = bound052203;
 load ubound0new.dat, bound3 = ubound0new;

bound = 0;
%for i=1:41,
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
%hold off,figure(1); imagesc(0:0.1:6.4,0:0.1:4.0,phase(1:41,:)), colormap(gray), axis xy, hold on, 
hold off,figure(1); imagesc(0:0.1:6.4,0:0.1:4.5,phase(1:46,:)), colormap(gray), axis xy, hold on, 

for i = 1:280
%for i=1:275,
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
% figure(1),imagesc(0:0.1:5.4,2.0:0.01:2.74,bound(201:275,:)),axis xy,% figure(2), imagesc(bound),bound =0;

for j=1:550,
%for j=1:547,
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
% figure(1),imagesc(5.20:0.01:5.47,0:0.1:2.0,bound(1:21,520:547)), axis xy,
 plotphasediagram0
% plotphasediagram90

hold off
clear i, clear j, clear bound2, clear bound3 , clear bound;clear phase0, clear phase,