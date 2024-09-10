% find the peak in 1-D case. Use Gaussian Fit.
% x0 = peak1d(a); a is the 1 D arrey.

  function x0 = peak1d(a);
   a=a-min(a(:))+1; 
   a_size = size(a);
   if a_size(2) ==1, a=a'; end
   L = length(a);
   pk9 = find(a == max(a(:)));
   
a99 = median(pk9); pk9 = 0; pk9 = a99;
low_a = max(pk9-3, 1);
high_a = min(pk9+3, L);
pk=(low_a:high_a);
pf1=polyfit(pk,log(a(pk)),2);
if pf1(1)==0, x0 = 1;
else   x0 = (-1)*(pf1(2)/(2*pf1(1)));
end ;  
x0 = max(1,x0);
x0 = min(L,x0);
   
%if length(pk9)>1, a99 = (pk9(1));pk9=0;pk9=a99; end
%    n =2;
%if pk9(1) <=4 & pk9 > 1  , n=pk9-1;    end 
%if (pk9(1) ==length(a)-1)|(pk9(1)==2), n = 1;  end
% 
%if pk9 ==1, x0 = 1;  
%elseif pk9(1) ==length(a), x0 = length(a); 
%else
%   pk=(pk9(1)-n):(pk9(1)+n);
%  %pk9 =pk9,n=n,a(pk),pk,
%   if pk9>3,
%      pf1=polyfit(pk,log(a(pk)),2);%figure(2); plot(log(a(pk)))
%   else
%      pf1=0;
%   end    
%if pf1(1)==0, x0 = 1;
%else   x0 = (-1)*(pf1(2)/(2*pf1(1)));
%end ;  
%end;
%x0=x0;%%
