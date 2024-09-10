% Find the k of a small area use the wavelet trans. calculate 
%  only the center point
%  [k,ang] = wave4k(a,y,x)

   function  [k,ang] = wave4k(a,y,x);
   
   step =0.5; a0 = 0.5;ran = 512;
   [l,m] = size(a);
   cy = cwt(a(y,:),a0:step:ran,'cgau7');d=0;
   d = abs(cy(:,y))';
   p = peak1d(d,50);
   if length(p) > 1, ky = 0;
   else  ky = l*(centfrq('cgau7') /(step*p));
   end
%   x = x 
   cx = cwt(a(:,x),a0:step:ran,'cgau7');d=0;
   d = abs(cx(:,y))';
   p = peak1d(d,50);
   if length(p) > 1, kx =0; 
   else   kx = m*(centfrq('cgau7') /(step*p));
   end

   k = sqrt(kx*kx + ky*ky);
   if kx == 0, ang = (ky)/(abs(ky))*pi/2;
   else   ang = atan(ky/kx);
   end
