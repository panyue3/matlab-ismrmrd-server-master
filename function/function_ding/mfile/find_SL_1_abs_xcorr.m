% function [sl_1, ang, hex_out,hex_ang] = find_SL_1_abs_xcorr(a2,a2f,p2,p2f,a6,a6f,a7,a7f,p7,p7f)

function [sl_1, ang, hex_out,hex_ang] = find_SL_1_abs_xcorr(a2,a2f,p2,p2f,a6,a6f,a7,a7f,p7,p7f)
   
A20 = 0 ;
for A2 = a2:10:a2f
for Phi7=p7:1:p7f; 
    phi=0; A20 = A20+1;
for Phi2=p2:10:p2f;
    phi=phi+1;
for A6=a6:100:a6f
    n6 = A6/100; 
    sl = 0;
    for A7 = a7:10:a7f
        n7 = A7/10;
        fname = sprintf('%i_%i_%i_%i_%i',A6,A7,Phi7,A2,Phi2),      
        a0 = readin_160_120_file(fname); 
        i00 = size(a0)
        a0 = reshape_128_128(a0,0.0618);
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))); 
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001);
            e = sum(a(:,20:24),2);  			e = e - mean(e(:));			% figure(2), plot(e)
            e = my_xcorr(e,e); 				emin = min(e); 				emax = max(e);	
            peak0 = e(11:51);				peak1 = e(311:351); 			peak2 = e(51:71);     
            [sl0_0, ang0_0] =  findpeakval(peak0);      [sl0_1, ang0_1]= findpeakval(peak1); 	[hex(i),ang0_2] = findpeakval(peak2);	
            if sl0_0(1) > sl0_1(1),
		sl1(i) = sl0_0(1); 		ang1(i) = 9 + ang0_0(1);
	    else
		sl1(i) = sl0_1(1); 		ang1(i) = 51 - ang0_1(1);
	    end	    
	    ang2(i) = 49 + ang0_2 ;
        end
	N = find(sl1 == max(sl1(:)));		N_hex = find(hex == max(hex(:)));
        %sl_1(n6,n7)=max(sl1(:)); 		%sl_1(phi) = max(sl(:));
        %sl1,ang1
       	sl_1(n6,n7) = max(sl1(:));		ang(n6,n7) = ang1(N(1));
        hex_out(n6,n7) = max(hex(:));		hex_ang(n6,n7) = ang2(N_hex(1));
    end
end ; 	end ; 	end ; 	end
