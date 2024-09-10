px = xp(1,:);   py = yp(1,:);
px = px(find(px~=0)); py = py(find(py~=0));
%plot(px,py,'*')
[vx0,vy0]=strain_field(px,py,9.8);
quiver(px,py,vx0,vy0)
