phase = phase90; bound_2=bound060303; bound_3=upperbound90; 
for i = 1:41     
    for j=1:65
        if phase(i,j)==0, 
            phase(i,j)=6;
        elseif phase(i,j)==0.5, 
            phase(i,j)=5.5;
        elseif phase(i,j)==1, 
            phase(i,j)=5;
        elseif phase(i,j)==2, 
            phase(i,j)=4;    
        elseif phase(i,j)==3, 
            phase(i,j)=3;
        elseif phase(i,j)==4, 
            phase(i,j)=2;
        elseif phase(i,j)==5, 
            phase(i,j)=5;
        elseif phase(i,j)==6, 
            phase(i,j)=0;
        elseif phase(i,j)==7, 
            phase(i,j)=5;
        elseif phase(i,j)==8, 
            phase(i,j)=5;
        elseif phase(i,j)==9, 
            phase(i,j)=5;    
        end    
    end
end
hold off, imagesc(0:0.1:4.0,0:0.1:6.4,phase(1:41,:)'), colormap(gray), axis xy, hold on
for i=1:275,
    for j=1:55
        if bound_2(i,j)==0
            bound(i,j)=6;
        elseif bound_2(i,j)==0.5, 
            bound(i,j)=5.5;
        elseif bound_2(i,j)==1, 
            bound(i,j)=5;
        elseif bound_2(i,j)==2, 
            bound(i,j)=4;    
        elseif bound_2(i,j)==3, 
            bound(i,j)=3;
        elseif bound_2(i,j)==4, 
            bound(i,j)=2;
        end
    end
end
imagesc(2.00:0.01:2.75,0:0.1:5.2,bound(200:275,1:53)')
for i=1:25,
    for j=1:547,
        if bound_3(i,j)==0
            bound3(i,j)=6;
        elseif bound_3(i,j)==0.5, 
            bound3(i,j)=5.5;
        elseif bound_3(i,j)==1, 
            bound3(i,j)=5;
        elseif bound_3(i,j)==2, 
            bound3(i,j)=4;    
        elseif bound_3(i,j)==3, 
            bound3(i,j)=3;
        elseif bound_3(i,j)==4, 
            bound3(i,j)=2;
        end
    end
end
imagesc(0:0.1:2.0,5.2:0.01:5.45,bound3(1:21,520:547)')
plotphasediagram(phase90), hold off
clear i, clear j, clear bound_3; clear bound_2;clear bound2, clear bound