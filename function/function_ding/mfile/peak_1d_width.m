% find the peak in 1-D case. Use Gaussian Fit.
% x0 = peak1d(a); a is the 1 D arrey.

function [x0,width] = peak_1d_width(a);
     
  a=a - min(a(:))*1.0001 ;    a_size = size(a);
  if a_size(2) ==1, a=a'; end
  l = length(a);
  pk9 = find(a == max(a(:)));
  if length(pk9)>1, a99 = (pk9(1));pk9=0;pk9=a99; end
  n1 =2;        n2 = 2;
  if (pk9(1)==2),               n1 = 1;  end
  if (pk9(1) ==length(a)-1),    n2 = 1;  end
 
  if pk9 ==1, x0 = 1;  width = 0;
  elseif pk9(1) ==length(a), x0 = length(a); width = 0;
  else
      pk=(pk9-n1):(pk9+n2); 
      pf1=polyfit(pk,log(a(pk)),2);
      x0 = (-1)*(pf1(2)/(2*pf1(1)));
      if pf1(1) < 0; width = 1/sqrt(-pf1(1));
      else width =0;
      end
  end    
  