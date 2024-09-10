% [k,th] = localk(a,lenperpix) a is the image, k is 
% the output k field. th is the direction field

function [kf,th] = localk(a,lenperpix);

%close all hidden

'finding local k, wait...'
%a=lpfilter(a,.3,.33);
a = a - mean(a(:));
[l,m] = size(a);
k0 = roughk(a);
[kx,ky] = diff2(a,lenperpix);

[dx,dy] = gradient(a);
[dxx,d0xy] = gradient(dx);
[d0yx,dyy] = gradient(dy);
%kx =1/ (lenperpix*lenperpix)*dxx(2:l-1,2:m-1) ; 
%ky = 1/(lenperpix*lenperpix)*dyy(2:l-1,2:m-1) ;
dxy = 1/(lenperpix*lenperpix)*(d0xy(2:l-1,2:m-1)+d0yx(2:l-1,2:m-1))/2;

b = a(2:l-1,2:m-1);
size(kx)
kx = -kx./b;
ky = -ky./b;
si = -sign(dxy./b);
figure(3)
img(kx)
colorbar
kf1 = kx+ky;

kf1 = (1-((kf1) < 0)).*kf1;
kf = sqrt(kf1);
kf = clean(kf,k0,0.2);

th=atan2(si.*sqrt(ky),sqrt(kx));
%th=atan2(sqrt(ky),sqrt(kx));

kf = lpfilter(kf,0.12,0.13);	
th=lpfilter(th,0.12,0.13);

'finding local K finish'
