
function e = find_SL_1_xcorr(A2,Phi2)

for A6=3000:100:5000
    n6 = A6/100; sl = 0;
    for A7 = 600:10:800
        n7 = A7/10;
        fname = sprintf('%i_%i_%i_%i',A2,Phi2,A6,A7),      
        a0 = readin_160_120_file(fname); 
        i00 = size(a0)
        a0 = reshape_128_128(a0,0.0618);
        stand(1:360,3) = 1/60 ;
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))); 
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001);
            e = sum(a(:,21:24),2);  e = e - mean(e(:)); plot(e), pause(2)
            if max(e(:))>5,
                p = find(e == max(e(:))); 
                p01 = mod(p(1),60);     if p01==0, p01 = 60 ;end 
                p02 = mod(p(1)-22,60) ; if p02==0, p02 = 60 ;end 
                p03 = mod(p(1)+22,60) ; if p03==0, p03 = 60 ;end 
                stand(p01:60:360,1) = 1; stand(p02:60:360,2) = 1; stand(p03:60:360,3) = 1;
                corr0(1) = sum(e.*stand(:,1));
                corr0(2) = sum(e.*stand(:,2));
                corr0(3) = sum(e.*stand(:,3));
                sl(i) = max(corr0(2:3))/corr0(1);
            else
                sl(i) = 0;
            end
        end
        k(n6,n7)=max(sl);        
    end
end