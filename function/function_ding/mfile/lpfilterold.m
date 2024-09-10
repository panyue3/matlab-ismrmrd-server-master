function [a]=lpfilter(b,lo,hi)
[sx,sy] = size(b);
s2 = sx/2;
lo = lo*s2;
hi = hi*s2;
lo2=lo*lo;
hi2=hi*hi;
fprintf(2,'%f %f %f\n',sx,lo,hi);
mb=mean(b(:));
a=fftshift(fft2(b-mb));
for i = 1:sx,
  for j = 1:sy,
     r = (i-s2)^2+(j-s2)^2;
     if r>hi2
       a(i,j)=0+i*0;
     elseif r>lo2
       r = sqrt(r);
       mlt = (hi-r)/(hi-lo);
%       fprintf(2,'%i %i %f\n',i,j,mlt);
       a(i,j) = mlt*a(i,j); 
    end
  end
end
a=real(ifft2(ifftshift(a)))+mb;
