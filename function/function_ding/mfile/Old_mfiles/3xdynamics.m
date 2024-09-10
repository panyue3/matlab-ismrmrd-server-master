function = 3xdynamics(n)
x1=n,x2=0;
while x1~=x2
if floor(x1/2)==x1; x2=x1/2;
else x2=(3*x1-1)/2;
x1=x2,
end
end
