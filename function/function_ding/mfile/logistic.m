function   logistic(a,b,n)
close all hidden;
 
a = double(a); b = double(b); n = double(n);
m=0;y(100*(n+1),2)=0;x0=0;
x=zeros(200:1);
for r=a:(b-a)/n:b
    x0 = rand;
    for k = 1:400, x0 = mod(r*x0*(1-x0),1); end
    x(1,1) = x0;
    for j = 2:200
        x(j,1) = mod(r*x(j-1,1)*(1-x(j-1,1)),1);
    end 
 
    y(200*m+1:200*(m+1),1) = x(1:200,1) ;
    y(200*m+1:200*(m+1),2) = r;
    m = m+ 1;   
end

plot(y(:,2),y(:,1),'.')

clear all
