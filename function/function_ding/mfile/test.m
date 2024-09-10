close all hidden
clear all
k = 0; kval = 0 ; b9 = 0; i = 0;
wavelength = 0 ;
for j = 0 : 0
   lenperpix = 1 ;decifac = 1 ;
   i = i + 1 ;
   fname =sprintf('/home/lab/shared/paul/sand/HexPhonons/%3i.bmp',j)
   a9 = imread(fname);
   if i ==1, [x,y,r]=findcen(a9);end
   [a, lenperpix,decifac] = cutimg(a9,x,y,r);

    tryw
end
    

