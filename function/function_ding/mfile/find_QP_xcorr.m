function qp = find_QP_xcorr(a2,p2)

%A2=0; Phi2=0; close all hidden
ang1 = 0;
for Phi2=a2:10:100; 
    ang1 = ang1+1; ang2 =0;phi=0;
for Phi5=p2:10:170;
    phi=phi+1; ang2 = ang2 + 1;
for A4=4600:100:4600
    n4 = A4/100; qp_8=0;    qp_12=0; n5=0;
    for A5_0 = 460:10:460
        n5 = A5_0/10;
       % n5 = n5+1;
        fname = sprintf('%i_%i_%i_%i_%i',A4,A5_0,Phi5,80,Phi2),      
        a0 = readin_160_120_file(fname); 
        i00 = size(a0)
        a0 = reshape_128_128(a0,0.0618);
        stand(1:360,3) = 1/60 ;
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))); 
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001);
            e = sum(a(:,19:22),2);  e = e - mean(e(:)); % plot(e), pause(5)
            e = xcorr(e); emin = min(e(:)); emax = max(e(:));
            %qp_8 =(e(find(e==emax(1))+45)+e(find(e==emax(1))-45)-2*emin(1))/(emax(1)-emin(1))/2;
            %qp_10 = (e(find(e==emax(1))+36)+e(find(e==emax(1))-36)-2*emin(1))/(emax(1)-emin(1))/2;
            qp_12 = (e(find(e==emax(1))+30)+e(find(e==emax(1))-30)-2*emin(1))/(emax(1)-emin(1))/2;
        end
        %qp(1,ang1,ang2)=max(qp_8);
        %qp(2,ang1,ang2)=max(qp_10);
        ang1, ang2, 
        qp(ang1,ang2)=max(qp_12);
    end
end
end
end
