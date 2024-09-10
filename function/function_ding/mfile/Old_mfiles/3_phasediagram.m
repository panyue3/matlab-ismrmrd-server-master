% Another phase diagram
function c0 = 3_phasediagram ;
name3 = 2800 ; name4 = 610 ;
for i=1:12
    name1 = 25 *i ;
    for j= 0:35
        name2 = 10*j ;
        fname = sprintf('%i_%i_%i_%i',name1,name2,name3,name4);
        fid = fopen(fanme);
        for n = 1:20,
            a = 0 ;
            a(1:160,1:120) = fread(fid,[160,120],'uchar');
            b(1:64,1:64,n) = a(38:101,31:94);
            if n >= 11,
                j1=fft2(b(:,:,n)-mean(mean(b(:,:,n))));
                j2=fft2(b(:,:,n-10)-mean(mean(b(:,:,n-10))));
                jb1=(b(:,:,n));
                jb2=(b(:,:,n-10));
                ja=real(ifft2(j1.*conj(j2)))/(std(jb1(:))*std(jb2(:))*64^2);
                c(n) = max(ja(:));
            end
        end
        c0(i,j) = median(c);
        
    end
end
