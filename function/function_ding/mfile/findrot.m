% Find the rotation of the two pattern.
% angle = findrot(a,b,modu)
% a,b are two image;  mode, hex = 60 
% angle = mod(angleb-anglea,modu)

 function angle = findrot(a,b,mode)

 k10 = roughk(a);  k20 = roughk(b);

 [ang1,phi1] = findang(a,1,k10);
 [ang2,phi2] = findang(b,2,k20);

 angle = mod(ang2-ang1,mode);
