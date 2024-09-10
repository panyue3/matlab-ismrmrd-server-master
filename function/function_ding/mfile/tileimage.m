function c0 = tileimage(in)
% close all hidden
totalimage =12; m=3; n=6; stepshift = 11.4;
k = 0 ; a = 0 ; b = 0 ; b0 = 0 ; b1 = 0 ; n0 = 1; n2=0;
j00 = in;
a3 = 0;
for p3 = 0:1:0;
    n2 = n2 + 1;
for i = 3400:100:5000
% for i = 2500-(20*(i1/10-31)):100:4000-(20*(i1/10-31))   
for j = j00
    k=k+1;a=0;b=0;
    fname = sprintf('%i_%i_%i_%i',p3,a3,i,j),
    % if k ==1, fname, end 
    fid=fopen(fname); a=0; 
    for i0=1:21,
        a0(1:160,1:120,i0)=fread(fid,[160,120],'uchar');
        a = a+a0(:,:,i0);
    end
    fclose(fid);
    b(1:64,1:64)=a(38:101,31:94)+1;    
    b11(1:64,1:64,1:i0) = a0(38:101,31:94,1:i0)+1;
    fnamemov = sprintf('%i_%i_%i_%imov',p3,a3,i,j);
    fid=fopen(fnamemov); a=0; 
    amov=fread(fid,[160,120],'uchar');
    fclose(fid);
    bmov(1:64,1:64)=amov(38:101,31:94)+1;        
    if k == 1, b0 = lpfilter(b,0.0618)+1; end
    b = b./ b0 ; bmov = bmov./ b0 ; b00 = bmov;    
    [x,y]=meshgrid(1:64,1:64);
    b=b.*exp(-((x-33).^2+(y-33).^2)./1000);
    bmov=bmov.*exp(-((x-33).^2+(y-33).^2)./1000);
    b1 = abs(fftshift(fft2(b-mean(b(:))))); b1(31:35,31:35)=0;
    b1mov = abs(fftshift(fft2(bmov-mean(bmov(:))))); b1mov(31:35,31:35)=0;
    b11fft=0;
    for i=1:i0;
        b11(:,:,i) = b11(:,:,i)./b0;   
        b11(:,:,i) = b11(:,:,i).*exp(-((x-33).^2+(y-33).^2)./1000); 
        b11fft = b11fft + abs(fftshift(fft2(b11(:,:,i0))))/(i0);   % imagesc(b11(:,:,i)), pause(5)
    end 
    b11fft(31:35,31:35)=0;
    figure(1), subplot(m,n,k), imagesc(b1), axis image, axis xy
    figure(2), subplot(m,n,k), imagesc(b11fft), axis image, axis xy;
    figure(3), subplot(m,n,k), imagesc(b1mov), axis image, axis xy;
    figure(4), subplot(m,n,k), imagesc(b00), axis image, axis xy;
end

b(1:64,1:64,1:20)=a0(38:101,31:94,1:20);
for i = 1:10,
j1=fft2(b(:,:,i)-mean(mean(b(:,:,i))));
j2=fft2(b(:,:,i+10)-mean(mean(b(:,:,i+10))));
jb1=(b(:,:,i));
jb2=(b(:,:,i+10));
ja=real(ifft2(j1.*conj(j2)))/(std(jb1(:))*std(jb2(:))*64^2);
c(i) = max(ja(:));
end
c0(n2) = median(c(:));
n0 = n0+1;
end
end
