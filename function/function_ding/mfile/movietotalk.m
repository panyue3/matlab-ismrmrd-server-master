% function k = movietotalk(filein)
% k is the total k, sepc is the 1-D sepctrum
% ft is the 2-D fft

function k = movietotalk(filein)   

i=1; N=128;n=0;factor=4;
fid=fopen(filein,'r','b'),
x1 = fread(fid,1,'uint32');
y1 = fread(fid,1,'uint32');

a=fread(fid,[636,479],'uchar');
% figure(3);imagesc(a);
 
w = hanning(512); v = hanning(512);  win = w*v';
meana = mean(a(:));
% circle mask
    [x0,y0] = meshgrid(1:479,1:636);size(x0);
    mask = (sqrt((x0-234).^2+(y0-316).^2)< 222);
% Apply mask
    a0 = a.*mask+meana*(1-mask);
%  figure(4); imagesc(a0);  
% Find the envelope
    b=lpfilter(a0,0.05,.06);

while prod(size(a))==636*479,
         if i == 1,
     a0 = a.*mask+meana*(1-mask);
     a0=a0./b; a=ones(512,512);
     a(1:512,1:479) = a0(51:562,1:479);
     a = a - mean(a(:));
     a = deci(a,factor); a = embed(a,factor);
%    imagesc(a);a = a - mean(a(:));
     
      k(i) = roughk(a)/factor;

         break,  end
      
  a=fread(fid,[636,479],'uchar');
  i=i+1,
        
end


