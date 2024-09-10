function k = find_SL_1_new(a2,p2)

for A2=a2:1:0;
    phi=0;
for Phi2=p2:1:0;
    phi=phi+1;
for A6=4000:100:5500
    n6 = A6/100;
    sl = 0;
    for A7 = 400:10:490
        n7 = A7/10;
        fname = sprintf('%i_%i_%i_%i_%i',A6,A7,Phi2,0,0),
        a0 = readin_160_120_file(fname);
        i00 = size(a0)
        a0 = reshape_128_128(a0,0.0618);
        stand(1:360,3) = 1/60 ;
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i))));
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001);
            % e = lpfilter(e,0.6);
            e = sum(a(:,21:24),2);  e = e - mean(e(:)); % plot(e), pause(5)
            e = xcorr(e); emin = min(e); emax = max(e);
            sl = (e(find(e==emax(1))+22)+e(find(e==emax(1))-22)-2*emin(1))/(emax(1)-emin(1))/2;
        end
        k(n6,n7)=max(sl(:));
        %k(A2,phi)=max(sl(:));
        %k(phi) = max(sl(:));
    end
end
end
end
