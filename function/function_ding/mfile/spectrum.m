%
%  [spec,ft] = spectrum(a) a is a 2-D image
%  spec is the 1-D spectrum(average over athmuthal direction)
%  ft is the 2-D fft of a

function   [spec,ft] = spectrum(a) 
    
   a = a -mean(a(:));
   ft = abs(fftshift(fft2(a)));
   
   [x0,y0]=size(a);
   cx0=floor(x0/2)+1;
   cy0=floor(y0/2)+1;
   b0rt=xy2rt(ft,cx0,cy0,1:cx0,-pi:0.01:pi);
   spec=sum(b0rt);


