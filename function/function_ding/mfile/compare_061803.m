fid = fopen('5800_0'); 
    a = 0 ;
    atotal = 0 ;
    for i0 = 1:20,
        a0(1:160,1:120,i0) = fread(fid,[160,120],'uchar');
        if i0 == 1
            bound(1:120) = a0(1,1:120,1);bound(121:240) = a0(128,1:120,1);
            b = median(bound(:));
            a00 = ones(128,128)* b ;
            a = ones(128,128,20)*b ;
            a00(1:128, 5:122 ) = a0(1:128, 3:120, 1) ;
            a00 = lpfilter(a00,0.0618); 
            if min(a00(:))==0
                a00=a00+1;
            end
        end
            
            a( 1:128, 5:122, i0  ) = ((a0(1:128,3:120,i0)./a00);
            afft0( 1:128, 1:128, i0  ) = ( fftshift( fft2( a(:,:,i0 ) ) ) );
            afft = abs( afft0);        
    end
    atotal = sum(a,3) ;
    fclose(fid);
    a01(1:128,1:128) = a(:,:,2);
    a02(1:128,1:128) = a(:,:,3);
    a01 = 64*a01/(mean(a01(:)));
    a02 = 64*a02/(mean(a02(:)));
    close all hidden
    %figure(1), imagesc(a01), figure(3), imagesc(abs(fftshift(fft2(a01-mean(a01(:))))))
    %figure(2); imagesc(a01-a02);figure(4), imagesc(abs(fftshift(fft2(a01-a02))))
    %figure(1),imagesc(a01), axis xy, axis image; figure(2),imagesc(a02),axis xy, axis image;
    clear a0, clear a00, clear a01, clear afft , clear a