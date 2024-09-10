% Another phase diagram
function c0 = stabilitydiagram_3 ;
name1 = 0 ; name2 = 0 ; 
for i=1:16
    name3 = 4400 + 100 * i ;
    for j= 0:1:50
        i0=1;
        name4 = 10*j ;
        fname = sprintf('%i_%i_%i_%i',name1,name2,name3,name4),
        %fname = sprintf('%i_%i',name1,name2),
        fid = fopen(fname);
        a00=fread(fid,[160,120],'uchar');
        a(1:160,1:120,i0) = a00;
        while prod(size(a00))==19200,
            a00=fread(fid,[160,120],'uchar');
            if prod(size(a00))==19200,i0=i0 + 1;a(:,:,i0)=a00;end;
        end
        i0,
        fclose(fid)
        a0 = sum(a,3)/i0; 
        a0 = lpfilter(a0,0.0618)+0.5; % imagesc(a0), pause(5)
        for m=1:i0,
            a(:,:,m) = a(:,:,m)./a0 ;
            b(1:64,1:64,m) = a(38:101,31:94,m);
            if m >= 11
                j1=fft2(b(:,:,m)-mean(mean(b(:,:,m))));
                j2=fft2(b(:,:,m-10)-mean(mean(b(:,:,m-10))));
                jb1=(b(:,:,m)); 
                jb2=(b(:,:,m-10));
                ja=real(ifft2(j1.*conj(j2)))/(std(jb1(:))*std(jb2(:))*64^2); 
                c(m-10) = max(ja(:));
            end
        end
               
        c0(i,j+1) = median(c);
        pause(0.1)
    end
end
