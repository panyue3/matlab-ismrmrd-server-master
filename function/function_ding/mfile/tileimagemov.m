function tileimagemov(i1)
totalimage =12;
m=5;
n=5;
k = 0 ; a = 0 ; b = 0 ; b0 = 0 ; b1 = 0 ;
for i = 2500:10:2740
for j = i1
    k=k+1;a=0;b=ones(128,128);
    fname = sprintf('%i_%i',i,j);
    fid=fopen(fname); a=0; 
    a=fread(fid,[160,120],'uchar');
    fclose(fid);
    b(1:128,1:120)=a(6:133,:)+1;
    if k == 1,
        b0 = lpfilter(b,0.0618)+1;
    end
    % figure(3), subplot(m,n,k), imagesc(b./b0), axis image, axis xy; 
    [x,y]=meshgrid(1:128,1:128);
    b=b.*exp(-((x-65).^2+(y-65).^2)./2000);
    b1 = abs(fftshift(fft2(b-mean(b(:))))); b1(64:66,64:66)=0;
    figure(2), subplot(m,n,k), imagesc(b1), axis image, axis xy;
end
end
clear m,clear n, clear a, clear a0,, clear b, clear b0, clear i,
clear j,clear k,clear fname, clear totalimage;clear x, clear y,
clear fid, clear b1;