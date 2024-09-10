% sand pile simulation of celluar automatabox
close all
m = zeros(100,100);
m(100,:)=1;, axis xy
%spy(m)
for i=1:4000
    if i<3997&(mod(i,2)==0)
        r1 = floor(4*rand) + 1; a = floor(50*rand(1,r1)) +50,
        for i0 = 1:r1,m(1,a(i0)) = 1;end; spy(m), pause(0.5)
        %m(2,:)=1;
    end
        for j0=1:2:98,
            j = j0 + mod(j,2);
            for k = 1:99 
                if sum(sum(m(j:j+1,k:k+1)))~=0&sum(sum(m(j:j+1,k:k+1)))~=4, %Not empty not full
            ul = m(j,k); dl = m(j+1,k); dr = m(j+1,k+1); ur = m(j,k+1);%spy(m), pause
            ul0 = ul - ul*(1-dl) - ul*dl*(1-dr)*(1-ur) ; % all the four are rules
            ur0 = ur - ur*(1-dr) - ur*dr*(1-dl)*(1-ul) ;
            dl0 = dl + ul*(1-dl) + (1-ul)*(1-dl)*dr*ur ;
            dr0 = dr + ur*(1-dr) + (1-ur)*(1-dr)*dl*ul ;
            m(j,k) = ul0; m(j+1,k) = dl0; m(j+1,k+1) = dr0; m(j,k+1) = ur0;% spy(m), pause
                end
            end
            
        end
    spy(m)
    pause(0.01)
end
end

