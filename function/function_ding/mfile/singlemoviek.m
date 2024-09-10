function k0 = singlemoviek(fname)

i0=1;
fid = fopen(fname);
a00=fread(fid,[160,120],'uchar');
a(1:160,1:120,i0) = a00;
while prod(size(a00))==19200,
    a00=fread(fid,[160,120],'uchar');
    if prod(size(a00))==19200,i0=i0 + 1;a(:,:,i0)=a00; end;
end
i0,
fclose(fid)
a0 = sum(a,3)/i0;
a0lp = lpfilter(a0,0.06);
b0(1:64,1:64) = a0(38:101,31:94);
%figure(1),imagesc(a0lp),colorbar; figure(2), imagesc(a(:,:,i0-1)), colorbar
%figure(1), imagesc(a(:,:,i0-1)./a0lp), colorbar
for i=1:i0-1
    a(:,:,i) = a(:,:,i)./(a0lp+0.5); ;
    b(1:64,1:64,i) = a(38:101,31:94,i);
    b(:,:,i) = b(:,:,i) -mean(mean(b(:,:,i)));
    b(:,:,i) = hpfilter(b(:,:,i), 0.05);
    b(:,:,i) = lpfilter(b(:,:,i), 0.8);
    bfft(1:64,1:64) = abs(fftshift(fft2(b(:,:,i))));
    d = xy2rt(bfft,33,33,1:50,0:0.1:2*pi);  
    e = sum(d,1).*(1:50); 
    k0(i) = peak1d(e);
    if i ==i0-1, imagesc(d),end
    %imagesc(bfft),pause(1)
    %plot(e), pause(1)
end
    
% figure(1), imagesc(sum(b(:,:,:),3))

