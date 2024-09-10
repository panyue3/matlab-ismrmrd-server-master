m=0;n=0;
%theta=0;at=0;dif=0;delta=0;
for i = 240:4:292
    m=m+1; n=0;
    for j = 0:10:355
       n=n+1;
       fname = sprintf('%i_%i',i,j),
       ifonset(m,n)=checkifonset(fname);  
    end
end

clear m, clear n, clear fname,clear i, clear j,

ifonsetn = (ifonset-min(ifonset(:)))/(max(ifonset(:))-min(ifonset(:)));
