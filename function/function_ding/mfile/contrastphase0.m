phase = phase0; bound_2=bound052203; bound_3=upperbound0;
for i=1:51,
%for i = 1:41     
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
hold off, imagesc(0:0.1:4.0,0:0.1:6.4,phase(1:41,:)'), colormap(gray), axis xy, hold on
for i=1:280,
    for j=1:54
        if bound_2(i,j)==0
            bound2(i,j)=6;
        elseif bound_2(i,j)==0.5, 
            bound2(i,j)=5.5;
        elseif bound_2(i,j)==1, 
            bound2(i,j)=5;
        elseif bound_2(i,j)==2, 
            bound2(i,j)=4;    
        elseif bound_2(i,j)==3, 
            bound2(i,j)=3;
        elseif bound_2(i,j)==4, 
            bound2(i,j)=2;
        end
    end
end
imagesc(0:0.01:2.79,0:0.1:5.3,bound2')
for i=1:25,
    for j=1:545,
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
imagesc(0:0.1:2.1,5.2:0.01:5.45,bound3(1:22,520:545)')
plotphasediagram(phase0)
clear i, clear j, clear bound2, clear bound3, clear bound_2, clear bound_3