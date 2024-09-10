function plotphasediagram(phase0)
phase=phase0;
[i0,j0]=size(phase0), markersize=4;
% close all hidden,
imagesc(0:0.1:i0/10,0:0.1:j0/10,6 - phase0'), axis xy, colormap(gray)
hold on
% for i=1:i0,for j=1:j0, plot(0.1*(i-1),0.1*(j-1),'','color',[1 1 1]),end,end
for i=1:i0,for j=1:j0, if phase(i,j)==0,plot(0.1*(i-1),0.1*(j-1),'','color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==0.5,plot(0.1*(i-1),0.1*(j-1),'o','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==1,plot(0.1*(i-1),0.1*(j-1),'s','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==2,plot(0.1*(i-1),0.1*(j-1),'x','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==3,plot(0.1*(i-1),0.1*(j-1),'h','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==4,plot(0.1*(i-1),0.1*(j-1),'*','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==5,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
for i=1:i0,for j=1:j0, if phase(i,j)==6,plot(0.1*(i-1),0.1*(j-1),'v','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:j0, if phase(i,j)==7,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:j0, if phase(i,j)==8,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
%for i=1:i0,for j=1:j0, if phase(i,j)==9,plot(0.1*(i-1),0.1*(j-1),'+','markersize',markersize,'color',[1 1 1]),end,end,end
hold off,

clear i,clear i0, clear phase, clear j, clear markersize