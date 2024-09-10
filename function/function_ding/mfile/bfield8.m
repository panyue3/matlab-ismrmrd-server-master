I(1)=0.2569;I(2)=0.2574;I(3)=0.2518;I(4)=0.2523;I(5)=0.2456;I(6)=0;I(7)=0.2456;I(8)=0.2469;I(9)=0.2433;
L=0;
%Cylindrical Coordinates
%inc = theta resolution
inc=pi/50;
%define theta=th array
th=0:inc:2*pi-inc;
%define array of 0.5 for radius
R2=0.5*ones(size(th));
%initialize mv=magnetic field 
mv=zeros(21,3);
%loop over radius from 1 to 30% larger (different layers)
for rm=1.003:0.0098:1.088,
   R=rm*R2;
   dl=max(R)*inc;
   L=L+1;
%iterate z over top half of the solenoid
  for z=0:0.0065:4.8,
    %calculate x and y position from R and theta (x,y are arrays)
    [x,y]=pol2cart(th,R);
%get dimensions of matrix x
    [a,b]=size(x);
%zhat = unit vector in z direction
    zh=[0, 0, 1];
    j=1;   
%p(xyz) = location where field is evaluated
    for py=0:R2/40:R2*0.97/2,
       px=0;
       pz=0;
%Calculate angle for cross product
       for i=1:b,
          tanr(i,:)=cross([x(i),y(i),0],zh);
       end
%Normalize 
       tanr=tanr/sqrt(dot(tanr(1,:),tanr(1,:)));
       m=0;
%rx,ry,rz is the vector from p(xyz) to xyz.
       rx=x-px;
       ry=y-py;
       rz=z-pz;
%       r=[rx,ry,rz];
%       rh=r/sqrt(sum(r.*r));
       for i=1:b,
          r=[rx(i),ry(i),rz];
          rh=r/sqrt(sum(r.*r));
%dM = dl X r_hat / r^2
          dm=I(L)*dl*cross(tanr(i,:),rh)/sum(r.*r);
          m=m+dm;
       end
%print out variables
%       m
%       j
%       z
%       rm
       mv(j,:)=mv(j,:)+m;
%       mv(j,:)
%each j corresponds to a different y (or r) location
       j=j+1;
    end  
  end
end

mv = 2 * mv * 0.01256;









