% function k = movie3k(filein)
% k is the total k, sepc is the 1-D sepctrum
% ft is the 2-D fft

function k = moviek(filein)

i=1; N=128;n=0;factor=4;
fid=fopen(filein,'r','b'),
x1 = fread(fid,1,'uint32');
y1 = fread(fid,1,'uint32');

a=fread(fid,[636,479],'uchar');

w = hanning(512); v = hanning(512);  win = w*v';
meana = mean(a(:));
% circle mask
    [x0,y0] = meshgrid(1:479,1:636);size(x0);
    mask = (sqrt((x0-234).^2+(y0-316).^2)< 222);
% Apply mask
    a0 = a.*mask+meana*(1-mask);
% Find the envelope
    bm=lpfilter(a0,0.05,.06);

while prod(size(a))==636*479,
%         if i == 1,
     a0 = a.*mask+meana*(1-mask);
     a0=a0./bm; a=ones(512,512);
     a(1:512,1:479) = a0(51:562,1:479);
     a = a - mean(a(:));
     a = deci(a,factor); a = embed(a,factor);
%    imagesc(a);a = a - mean(a(:));
     b0 =abs(fftshift(fft2(a)));

    b0rt=xy2rt(b0,257,257,1:256,-pi:0.01:pi);
%   figure(1),imagesc(b0rt);
       if i == 1, b = 0; b = b0rt(200:400,:);
%   figure(2), imagesc(b);     
    [x1,y1] = find(b == max(b(:))); x1 = x1+200,break 
       else, b = 0 ; b = b0rt(x1-25:x1+25,y1-5:y1+5);
    [x0,y0] =  find(b == max(b(:))); x1=x0+x1-25; y1=y0+y1-5;
       end
     
    b0sum1=sum(b0rt(x1-157:x1-52,:));
    b0sum2=sum(b0rt(x1-52:x1+52,:));
    b0sum3=sum(b0rt(x1+52:x1+157,:));
    b0sum1(1:20)=0; b0sum2(1:20)=0; b0sum3(1:20)=0;  
    k(i,1) = peak1d(b0sum1);
    k(i,2) = peak1d(b0sum2);
    k(i,3) = peak1d(b0sum3);
%         break,  end

  a=fread(fid,[636,479],'uchar');
  i=i+1,

end

