% Find k use 1-D continous wavelet transformation
%  b = cwt4k(a)

   function b = cwt4k(a);  

[l,m] = size(a);

in = 64 ; n1 = 0; 
'kx'
for i1 = 1:in:l
   c0 = cwt(a(i1,:),8:8:1024,'cgau7');
   c1 = cwt(a(i1,:),4.05:0.05:25,'cgau7');
   c2 = cwt(a(i1,:),24.2:0.2:140,'cgau7');
   c3 = cwt(a(i1,:),129:1:1024,'cgau7');
%   [l1,l2] = size(c);
   n1 = n1 + 1; n2 = 0;
   for i2 = 1:in:l
      n2 = n2 + 1;
      d = abs(c0(:,i2))';
      dm = find(d == max(d));
      if dm <=2, c = c1; a0 = 4;step=0.01;
      elseif dm>2 & dm<=128; c = c2;a0=24;step=0.2;
      elseif dm>128, c = c3; a0=128;step=1;
      else c = c0,a0=0;step=8 ;
      end
      [l1,l2] = size(c);
      d = abs(c(:,i2))';
      dm = find(d == max(d));
      if length(dm) >1
         kx(n1,n2) = 0;
      elseif dm > floor(l1*0.9)
         kx(n1,n2) = 0;
      elseif  max(d) < 2*median(d),
         kx(n1,n2) = 0;
      else
         kx(n1,n2) = l*(centfrq('cgau7') /(a0+step*peak1d(d,50)));
      end
   end  
end
'ky'
n1 = 0;
for i1 = 1:in:m
   n1 = n1 + 1; n2 = 0;
   c0 = cwt(a(:,i1),8:8:1024,'cgau7');
   c1 = cwt(a(:,i1),4.05:0.05:25,'cgau7');
   c2 = cwt(a(:,i1),24.2:0.2:140,'cgau7');
   c3 = cwt(a(:,i1),129:1:1024,'cgau7');
%   [l1,l2] =size(c);
   for i2 = 1:in:m
      n2 = n2 + 1 ;
      d = abs(c0(:,i2))';
      dm = find(d == max(d));
      if dm <=2, c = c1;a0=4;step=0.05;
      elseif dm>2 & dm<=128; c = c2;a0=24;step=0.2;
      elseif dm>128, c = c3;a0=128;step=1;
      else c = c0;a0=0;step=8;
      end
      [l1,l2] = size(c);
      d = abs(c(:,i2))';
      dm = find(d == max(d));
      if length(dm) > 1,
         ky(n2,n1) = 0;    
      elseif dm > floor(l1*0.9)&length(dm)== 1,
         ky(n2,n1) = 0; 
      elseif max(d)< 2*median(d)
          ky(n2,n1) = 0;
      else  
         ky(n2,n1) = l*(centfrq('cgau7') /(a0+step*peak1d(d,50)));
      end
   end   
end

b = sqrt(kx.*kx + ky.*ky);

