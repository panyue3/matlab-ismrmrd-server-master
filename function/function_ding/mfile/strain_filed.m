% Find the strain field of all the peaks 


function [vx,vy] = strain_field(px,py,a)

vx = zeros(1,n);
vy = zeros(1,n);
n = length(px);
for i=1:n
for j=1:n
    r2 = (px(i)-px(j))^2+(py(i)-py(j))^2;
    if r2 <1.5*a*a & r2 > 0.6*a*a
        theta = ang(px(j)-px(i),py(j)-py(i)); 
        vx(i) = vx(i)+(sqrt(r2)-a)*cos(theta);
        vy(i) = vy(i)+(sqrt(r2)-a)*sin(theta);
    end    
end
end