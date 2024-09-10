% This is a simple method to group the images into breath-out and diastole.


function [x,x1,x2] = Group_Cardiac_Images(a)

[a_r, V, D] = my_KL_reshape(a,1);

s = size(V);
m1 = V(:,s(1)-1);
m2 = V(:,s(1)-2);

[h,b]=hist(m1,5) ;
c = find(h==max(h)) ;
if c==1,
    x1 = find(m1 < (b(1)+b(2))/2 );
else
    x1 = find(m1 > (b(4)+b(5))/2 );
end
size(x1)

[h,b]=hist(m2,5) ;
c = find(h==max(h)) ;
if c==1,
    x2 = find(m2 < (b(1)+b(2))/2 ) ;
else
    x2 = find(m2 > (b(4)+b(5))/2 ) ;
end
size(x2)

j = 0;
for i=1:length(x1)
    if prod(x2-x1(i))==0
        j = j + 1;
        x(j) = x1(i);
    end
end
