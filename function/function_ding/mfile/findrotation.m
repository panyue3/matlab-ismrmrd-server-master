 i=0; 
for j = 3:7

   i = i + 1 ;
   fname =sprintf('052364048000%1i.dat',j)
   [a,peak,val] = intenang(fname);
   ang(j,1:length(abs(peak(1)-peak)))=abs(peak(1)-peak);
end
