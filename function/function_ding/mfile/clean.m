% b = clean(a,k0)

function b = clean(a,k0,thre);

meana = median(a(:));
maxa = max(a(:));
mina = min(a(:));

x0 = 0;y0 = 0; x1 = 0; y1 = 0 ;

% new

[x0,y0] = find(a > (1+thre)*meana | a < (1-thre)*meana);
[l,m] = size(a);
n=length(x0)
r0 = floor(l/k0)+1;
if mod( floor(r0),2 ) ==1,  r=(r0+1)/2; else r=r0/2 ;end;
[x,y] = meshgrid((1-l)/2:(l-1)/2,(1-m)/2:(m-1)/2);
b=ones(l,m);
b(x0,y0)=0;
b1 = b.*a;

for i = 1: n,
   [x,y] = meshgrid(x0(i)-r:x0(i)+r,y0(i)-r:y0(i)+r);
   if x0(i) > r & x0(i) < (l-r) & y0(i) > r & y0(i) < (m-r),
      z0 = exp(-((x-x0(i)).^2+(y-y0(i)).^2)/(r*r));
      c = b1(x0(i)-r:x0(i)+r,y0(i)-r:y0(i)+r).*z0;
      d = length(find(c));
      if d == 0,  a(x0(i),y0(i)) = meana; 
      else
      a(x0(i),y0(i)) =sum(c(:))/sum(sum((b(x0(i)-r:x0(i)+r,y0(i)-r:y0(i)+r).*z0)));
      end;
    end;
end;   
b=0;
b = a(r+1:l-r-1,r+1:m-r-1);
'cleaning finish!'





% new
%while maxa > (1+thre)*meana & mina < (1-thre)*meana,

%[x,y] = find(a == maxa)
%if length(x) > 50, break; end;
%if x==x0 & y==y0, a(x,y) = meana;'ha ha ha ha ha ha ha ha ha ha'
% end;
%a = blur(a,k0,x,y);
%meana = mean(a(:))
%x0 = x; y0 = y;
%maxa = max(a(:))

%[x,y] = find(a == mina)

%if length(x)==length(x1),
%if x==x1 & y==y1, 
%   for i=1:length(x), a(x(i),y(i)) = meana;end;
%'ha ha ha ha ha ha ha ha ha ha'
%end;
%end;

%a = blur(a,k0,x,y);
%meana = mean(a(:))
%x1 = x; y1 = y;
%mina = min(a(:));

%end

%b = a;
