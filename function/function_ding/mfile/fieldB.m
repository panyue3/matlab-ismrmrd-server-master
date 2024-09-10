%Cylindrical Coordinates
%inc = theta resolution
inc=pi/50;
%define theta=th array
th=0:inc:2*pi-inc;
%define array of 0.5 for radius
R2=ones(size(th));
%initialize mv=magnetic field 
mv1= zeros(200,3);
mv2= zeros(200,3);
mv = zeros(200,3);
%loop over radius from 1 to 30% larger (different layers)
for rm2=0.90846:0.02:1.00846,
   R=rm2*R2;
   dl2 = max(R)*inc ;
%iterate z over top half of the solenoid
  for z2=0.23532:0.005:0.33532,
     %calculate x and y position from R and theta (x,y are arrays)(I moved it)
     [x,y]=pol2cart(th,R);
     %zhat = unit vector in z direction
     zh=[0, 0, 1];
     j=1;   


     %get dimensions of matrix x
     [a,b]=size(x);
     %p(xyz) = location where field is evaluated
    for py=0:R2/200:R2*0.097,
       px=0;
       pz=0;
%Calculate angle for cross product
       for i=1:b,
          tanr(i,:)=cross([x(i),y(i),0],zh);
       end
%Normalize 
       tanr=tanr/sqrt(dot(tanr(1,:),tanr(1,:)));
       m2=0;
%rx,ry,rz is the vector from p(xyz) to xyz.
       rx=x-px;
       ry=y-py;
       rz=z2-pz;
%       r=[rx,ry,rz];
%       rh=r/sqrt(sum(r.*r));
       for i=1:b,
          r=[rx(i),ry(i),rz];
          rh=r/sqrt(sum(r.*r));
%dM = dl X r_hat / r^2
          dm2=dl2*cross(tanr(i,:),rh)/sum(r.*r);
          m2 = m2 + dm2;
       end
%print out variables
%       m
%       j
%       z
%       rm
       mv2(j,:)=mv2(j,:)+m2;
%       mv(j,:)
%each j corresponds to a different y (or r) location
       j=j+1;
    end  
  end
end

%print out variables
       mv2;
       
       
       
       
%loop over radius from 1 to 30% larger (different layers)
for rm1=0.602665:0.016518:0.685245,
   R=rm1*R2;
   dl1 = max(R)*inc;  
%iterate z over top half of the solenoid
  for z1=0.723765:0.0041295:0.806355,
    %calculate x and y position from R and theta (x,y are arrays)(I moved it)
    [x,y]=pol2cart(th,R);
    %zhat = unit vector in z direction
    zh=[0, 0, 1];
    j=1; 
    %get dimensions of matrix x
    [a,b]=size(x);
    %p(xyz) = location where field is evaluated
    for py=0:R2/200:R2*0.097,
       px=0;
       pz=0;
%Calculate angle for cross product
       for i=1:b,
          tanr(i,:)=cross([x(i),y(i),0],zh);
       end
%Normalize 
       tanr=tanr/sqrt(dot(tanr(1,:),tanr(1,:)));
       m1=0;
%rx,ry,rz is the vector from p(xyz) to xyz.
       rx=x-px;
       ry=y-py;
       rz=z1-pz;
%       r=[rx,ry,rz];
%       rh=r/sqrt(sum(r.*r));
       for i=1:b,
          r=[rx(i),ry(i),rz];
          rh=r/sqrt(sum(r.*r));
%dM = dl X r_hat / r^2
          dm1=dl1*cross(tanr(i,:),rh)/sum(r.*r);
          m1 = m1 + dm1;
       end
%print out variables
%       m
%       j
%       z
%       rm
       mv1(j,:)=mv1(j,:)+m1;
%       mv(j,:)
%each j corresponds to a different y (or r) location
       j=j+1;
    end  
  end
end
mv = mv1 + mv2 ;
%print out variables
      
       mv;










