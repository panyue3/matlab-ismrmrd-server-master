%load matlab100203.mat

sl1 = sl_1(40:55,55:75);    sl2 = sl_2(40:55,55:75);
x = 5.5:0.1:7.5;            y = 4.0:0.1:5.5;

colormap(gray)
subplot(2,2,1), image(x,y,sl1*64), colorbar, axis image
subplot(2,2,2), image(x,y,sl2*64),colorbar,axis image
subplot(2,2,3), imagesc(x,y,lpfilter(sl1,0.5)*64), colorbar, axis xy
subplot(2,2,4), imagesc(x,y,lpfilter(sl2,0.5)*64), colorbar, axis xy