% peak_1D(a) 

function x0 = peak_1D(a);
   a=a-min(a(:))+1; 
   a_size = size(a);
   if a_size(2) ==1, a=a'; end
   L = length(a);
   pk9 = find(a == max(a(:)));
   
a99 = median(pk9); pk9 = 0; pk9 = a99;
low_a = max(pk9-3, 1);
high_a = min(pk9+3, L);
pk=(low_a:high_a); a(pk);
pf1=polyfit(pk,a(pk),2);
if pf1(1)==0, x0 = 1;
else   x0 = (-1)*(pf1(2)/(2*pf1(1)));
end ;  
x0 = max(1,x0);
x0 = min(L,x0);
