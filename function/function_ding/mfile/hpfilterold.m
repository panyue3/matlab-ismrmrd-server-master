function [a]=filter(b,lo,hi)
[sx,sy] = size(b);
s2 = sx/2;
lo = lo*s2;
hi = hi*s2;
lo2=lo*lo;
hi2=hi*hi;
fprintf(2,'%f %f %f\n',sx,lo,hi);
a=fftshift(fft2(b-mean(b(:))));
for i = 1:sx,
  for j = 1:sy,
     r = (i-s2)^2+(j-s2)^2;
     if r<lo2
       a(i,j)=0;
     elseif r<hi2
       r = sqrt(r);
       mlt = (r-lo)/(hi-lo);
       a(i,j) = mlt*a(i,j); 
    end
  end
end
a=real(ifft2(ifftshift(a)));
