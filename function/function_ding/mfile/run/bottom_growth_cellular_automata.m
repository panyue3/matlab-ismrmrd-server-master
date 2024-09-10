% sand pile simulation of celluar automatabox
close all
m = zeros(100,100);
[x,y] = meshgrid(1:100,1:100); m = ((x-50).^2+(y-50).^2)<100;

for i=1:500
    if i<400
    r = floor(99*rand)+1;
    pi = floor(4*rand);
    vi = 1:2;
    if pi==0, vi=[2,r]; elseif pi==1, vi=[99,r]; elseif pi==2, vi=[r,2];else, vi=[r,99];end 
    end
    m(vi(1),vi(2))=1; spy(m), vi
    go = 1;
    while go == 1; 
        
    stepx = floor((2*rand-0.5)), stepy = floor((2*rand-0.5)),
    if (vi(1)-1)*(vi(1)-100)*(vi(2)-1)*(vi(2)-100) ==0 go = 0; m(vi(1),vi(2))=0;
        %elseif sum(min(1,m(vi(1))-1:max(100,vi(1))+1,min(1,m(vi(2))-1:max(100,vi(2))+1)) >1 ; go=0;
    elseif sum(m(max(1,(vi(1)-1)) :min(100,(vi(1)+1)) , max(1,(vi(2)-1)) : min( 100, (vi(2)+1) ) )) > 1.5; go =0; 
    else m(vi(1),vi(2))=0; vi(1)=vi(1)+stepx; vi(2) = vi(2)+stepy; m(vi(1),vi(2))=1; spy(m), pause(0.01)
    end
end   
%    for j=99:-1:1,
%        for k = 2:99,
%            if (m(j,k)*(sum(m(j+1,k-1:k+1)))+m(j,k))==1, m(j:j+1,k)=(0:1:1)';
%            end
%        end
%    end
    spy(m)
    pause(0.1)
end


