
close all hidden;
%clear all ;
a9 = imread('/home/lab/shared/ding/data/Dec01/122001/018.png','png');
%z4 = testhex(30,256); lenperpix =1/256; d = 1; r =100;
[z4,lenperpix,d,r] = cutimg(a9);

% band pass filter it from the very beginning.
z4 = lpfilter(z4,0.5,0.55);
z4 = hpfilter(z4,0.1,0.11);
z4 = wind(z4); % window it

figure(1)
%img(abs(fftshift(fft2(z4))));
img(z4)
title('original image');

%z4 = z4-mean(z4(:));
k0 = roughk(z4)
angle = findang(z4,3,k0);

z4 = decon(z4,angle(1)-pi/6,angle(1)+pi/6,0);
z4 = dewind(z4);

figure(2)
img(z4(10:246,10:246))
title('image after deconvolution')

z5 = z4(7:250,7:250);

[kff,kth] = localk(z5,lenperpix);

% cut the edge off
[sx,sy] =size(kff);
x0 =(1+sx)/2; y0 = (1+sy)/2;
[x,y] = meshgrid(1-x0:sx-x0,1-y0:sy-y0);
rr = sqrt(x.^2+y.^2);
c = (rr < r);
kff = kff.*c + (1-c)*mean(kff(:));

figure(3)  
img(kff)
title('K field')
colorbar

figure(4)
contour(kff,35)
title('K field contour')

meankff = sum(sum(kff.*c))/sum(c(:));
kff1 =100*c.*(kff - meankff)/meankff;
kff2 = kff1.*kff1;
rsm =sqrt (sum(kff2(:))/(sum(c(:))))

%for i =1: 254, k(i) = kff(i,i); end ;

figure(5)
img(kff1)
colorbar
title('percentage fluctuation of K')

figure(6)
img(kth)
colorbar
title('direction field')

