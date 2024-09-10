% Show the Superlattice mov images
% Do the FFT and then add the abs of the fft image
%
function k1 = show_slmov_img(fname)

    fid = fopen(fname); 
    a0 = 0 ; i00=1;
    atotal = 0 ;
    [x,y]=meshgrid(1:128,1:128);
    a00=fread(fid,[160,120],'uchar');
    a0(1:160,1:120,1) = a00;
    while prod(size(a00))==19200,
    a00=fread(fid,[160,120],'uchar');
    if prod(size(a00))==19200,i00=i00 + 1;a0(:,:,i00)=a00; end;
    end
    i00, 
    fclose(fid)        
    bound(1:120) = a0(1,1:120,1); bound(121:240) = a0(128,1:120,1);
    b = median(bound(:));
    a = ones(128,128,i00-1)* b ;
    a( 1:128, 5:122, 1:i00-1) = a0(6:133,3:120,1:i00-1);
    a00=sum(a,3);
    a00 = (lpfilter(a00,0.20));
    a0 = ones(256,256,i00-1);
    [x,y] = meshgrid(1:128,1:128); mask = exp(-((x-65).^2+(y-65).^2)/2000);
    % imagesc(mask), pause(2)
    for i0 = 1:i00-1,
            a(:,:,i0) = a(:,:,i0)./ a00 ;
            a0(:,:,i0) = ones(256,256)*min(min(min(a(:,:,i0))));
            a0(64:191,64:191,i0) = a(:,:,i0).*mask ; 
            afft0( 1:256, 1:256, i0  ) = abs( fftshift( fft2( a0(:,:,i0 ) ) ) );  
     end
    figure(1), imagesc(sum(a(21:100,21:100,:),3)./a00(21:100,21:100)); axis image, axis xy, colormap(gray)
    % imagesc(a0(:,:,i0)), colorbar,pause(5)
    afft = sum(afft0,3); 
    afft(126:132,126:132,:)=0;
    figure(2), imagesc(abs(afft(:,:)-max(afft(:)))), axis xy, axis image;colormap(gray)
    a = 0;
    a = xy2rt(afft,129,129,1:100,0:0.1:2*pi);
    e = sum(a,1).*(1:100); 
    e(1:15)=(0:1/14:1.0).*(e(1:15));% figure(2), plot(e),
    k1 = peak1d(e(1:90)),
    k2 = peak1d(e(1:50)),
    figure(3), plot(e),
    %pause(10),
    %for i = 11 : 22,
    %    figure(1), subplot(3,4,i-10), imagesc(a0(:,:,i)), axis image, axis xy,
    %    figure(2), subplot(3,4,i-10), imagesc(afft(:,:,i)), axis image, axis xy
    %end
    %figure(3), imagesc(a00), axis xy, axis image, min(a00(:))
        
    %fid = fopen(sprintf('%smov',fname));
    %a1 = fread(fid,[160,120],'uchar');
    %fclose (fid);
    %a(:,5:122,21) = a1(1:128,3:120);
    %a(:,:,21) = (a(:,:,21)./a00).*exp(-((x-65).^2+(y-65).^2)./500); 
    %a(:,:,22) = ((atotal/20)./a00).*exp(-((x-65).^2+(y-65).^2)./500) ;
    %afft(:,:,21 ) = abs( fftshift( fft2( a(:,:,21 ) ) ) );
    %afft(:,:,22 ) = abs( fftshift( fft2( a(:,:,22 ) ) ) );
    %afft(63:67,63:67,:) = 0 ;
    %a0(1:128,5:122,21) = a1(1:128,3:120) ;
    %a0(:,:,22) = atotal/20 ;