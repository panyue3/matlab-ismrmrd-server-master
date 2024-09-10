function result = dynamics3x(n)

p1=0;p2=0;p3=0;
for n=10000:100000
x1=n;x2=0;x0=0;do=1;n=n,
while x1~=x0&do==1
   x0=x1;
   if floor(x1/2)==x1/2
      x2=x1/2;
      while mod(x1,2)==0
          x2=x1/2;
          x1=x2;
      end
      x1=x1;
   else
      x2=(3*x1-1)/2;x1=x2;
      while mod(x1,2)==0
          x2=x1/2;
          x1=x2; 
      end
      x1=x1;
   end

if x1==1; p1=p1+1;do=0;end
if x1==5; p2=p2+1;do=0;end
if x1==91;p3=p3+1;do=0;end
end;
end;

result(1) = p1/n;
result(2) = p2/n;
result(3) = p3/n

