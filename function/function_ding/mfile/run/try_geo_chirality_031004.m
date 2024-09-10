% Try new model of geometric chirality
%
function  k = try_geo_chirality_031004(a0)
k = 0;a=0;
for i=1:2
    a1 = a0(:,:,i);
    a = imresize(a1,0.5,'bicubic');
    a = (a>2).*a/max(a(:)); %imagesc(a)
    a_size = size(a); N = a_size(1);%pause
for i1=1:N;for i2=1:N;                  
        for j1=1:N,
        if a(i1,i2)~=0    
        for j2=1:N;          
            for k1=1:N, 
            if a(j1,j2)~=0,
            for k2=1:N, 
                if a(k1,k2)~=0&(i1~=j1|i2~=j2)&(i1~=k1|i2~=k2)                        
                    rij = [i1-j1 i2-j2 0]; rik = [i1-k1 i2-k2 0];                        
                    k0 = 0.25*a(i1,i2)*a(j1,j2)*a(k1,k2)*cross(rij,rik)*(sqrt(sum(abs(rij)))-sqrt(sum(abs(rik))))./(sqrt(sum(abs(rij)))+sqrt(sum(abs(rik))));
                    k(i) = k(i)+ k0(3);
                end
             end,end,end
        end        
        end,end
end,i1,i=i,pause(10);if a(j1,j2)==0, break,end
end

