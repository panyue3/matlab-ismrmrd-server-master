% use the new method to find the local k
%

close all hidden
clear all
k = 0; kval = 0 ; b9 = 0; i = 0;
wavelength = 0 ;   
for j = 0 : 100
   lenperpix = 1 ;decifac = 1 ;
   i = i + 1 ;
   fname =sprintf('/home/lab/shared/paul/sand/HexPhonons/%3i.bmp',j)
   a9 = imread(fname);
   if i ==1, [x,y,r]=findcen(a9);end
   [z4, lenperpix,decifac] = cutimg(a9,x,y,r);

%   figure(1)
%   img(z4)
%    z4 = testhex(17.1,256);
   
   % Band pass filter image
   z4 = lpfilter(z4,0.5,0.55);
   z4 = hpfilter(z4,0.1,0.11);
   z4 = wind(z4);                               % window it
   [l0,m0] = size(z4);
   [k(i,1),ksd(i,1)] = findtotalk(z4,0);        % find the total K

   k0 = roughk(z4)
   [l1,l2] = size(z4);
   nb = floor(l1/k0/2) + 1
   angle = findang(z4,3,k0);

   for i0 = 1:1:3,
     [z,c] = decon(z4,angle(i0)-pi/6,angle(i0)+pi/6,0);
     [k(i,i0+1),ksd(i,i0+1)] = findtotalk(c,0);
%     z = dewind(z);
     z = fftshift(fft2(z));
     [kloc,thloc] = localk2(z,lenperpix);
%    nkloc = kloc(nb:l1-nb,nb:l2-nb);
     [m1,m2] = size(kloc);
     k(i,i0+4) = median(kloc(:));
     ksd(i,i0+4) = sqrt(sum(sum((kloc-k(i,i0+4)).^2))/(m1*m2-1));
   end
end

for i1 = 1:4,
    k(:,i1) = k(:,i1)*2*pi/256/lenperpix;
    ksd(:,i1) = ksd(:,i1)*2*pi/256/lenperpix;
end

