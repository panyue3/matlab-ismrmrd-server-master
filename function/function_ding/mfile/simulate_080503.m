close all
[x,y]= meshgrid(1:256,1:256);
k0=0.5; ka = 0.1913;
for phi_2=0:pi/2:2*pi, phi_2
for phi_1=0:0.3:6.3,phi_1,
a=cos(y*ka+phi_2+phi_1)+cos(-y*ka/2+1.732/2*ka*x+phi_2+phi_1)+cos(-y*ka/2-1.732/2*ka*x+phi_2+phi_1);
pattern = cos(k0*x+phi_1)+cos(k0*(-0.5*x+1.732/2*y)+phi_1)+cos(k0*(-0.5*x-1.732/2*y)+phi_1);
a(a>1.5)=1.5;    a(a<-1.5)=-1.5;
pattern(pattern>1.5)=1.5;pattern(pattern<-1.5)=-1.5;
imagesc(abs(pattern.*a)),axis xy,axis image,colormap(jet),pause(1),
end
end