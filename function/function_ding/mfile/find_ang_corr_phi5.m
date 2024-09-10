%[tt_out,ang_tt_out,qp_out,ang_qp_out,sl_out,ang_sl_out,
%hex_out,ang_hex_out,qp8_out,ang_qp8_out,qp10_out,ang_qp10_out] = find_ang_corr_phi5(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0) 

function [tt_out,ang_tt_out,qp_out,ang_qp_out,sl_out,ang_sl_out, hex_out,ang_hex_out,qp8_out,ang_qp8_out,qp10_out,ang_qp10_out] = find_ang_corr_phi5(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)

ang1 = 0;
for A2 = a2:10:a2f
for Phi2=p2:10:p2f;
    ang1 = ang1+1; ang2 =0;phi=0;
for Phi5=p5:1:p5f;
    phi=phi+1; ang2 = ang2 + 1;
for A4=a4:100:a4f
    n4 = A4/100; qp_8=0;    qp_12=0; n5=0;
    for A5_0 = a5:10:a5f
        A5 = round(A5_0*100);
        n5 = A5_0/10;
        fname = sprintf('%i_%i_%i_%i_%i',A4,A5_0,Phi5,A2,Phi2),
        a0 = readin_160_120_file(fname);
        i00 = size(a0),
        a0 = reshape_128_128_112103(a0,0.0618);
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))) ;
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001) ;
            e = sum(a(:,k0-2:k0+2),2);          e = e - mean(e(:)) ;                    % plot(e), pause(5)
            e = my_xcorr(e,e);                  emin = min(e(:)) ;                      emax = max(e(:)) ;
            peak0 = e(11:51);                   peak1 = e(311:351) ;     	            peak2 = e(51:71) ;
	        peak_sl0 = e(19:27);		        peak_sl1 = e(335:343) ;
	        peak_qp0 = e(27:35);		        peak_qp1 = e(327:335) ;
            peak_qp8 = e(42:50);		        peak_qp81 = e(312:320) ;
            peak_qp10 = e(33:41);		        peak_qp101 = e(321:329) ;
            [tt_0,ang_0] = findpeakval(peak0);  [tt_1,ang_1] = findpeakval(peak1) ;     [hex(i),ang0_2] = findpeakval(peak2) ;
	        [sl_0,sla_0] =findpeakval(peak_sl0);[sl_01,sla_1] =findpeakval(peak_sl1);
	        [qp_0,qpa_0] =findpeakval(peak_qp0);[qp_1,qpa_1] =findpeakval(peak_qp1);
            [qp8_0,qp8a_0] =findpeakval(peak_qp8);[qp8_1,qp8a_1] =findpeakval(peak_qp81);
            [qp10_0,qp10a_0] =findpeakval(peak_qp10);[qp10_1,qp10a_1] =findpeakval(peak_qp101);
            % plot(e),pause(1)
            if tt_0(1) >= tt_1(1),
                tt(i) = tt_0(1);               	ang1(i) = 9 + ang_0(1) ;
            else
                tt(i) = tt_1(1);               	ang1(i) = 51 - ang_1(1) ;
            end

            if sl_0(1) >= sl_01(1),
                sl_1(i) = sl_0(1);              ang_sl(i) = 17 + sla_0(1) ;
            else
                sl_1(i) = sl_01(1);             ang_sl(i) = 27 - sla_1(1) ;
            end

            if qp_0(1) >= qp_1(1),
                qp(i) = qp_0(1);              	ang_qp(i) = 25 + qpa_0(1) ;
            else
                qp(i) = qp_1(1);               	ang_qp(i) = 35 - qpa_1(1) ;
            end
            
            if qp8_0(1) >= qp8_1(1),
                qp8(i) = qp8_0(1);              	ang_qp8(i) = 40 + qpa_0(1) ;
            else
                qp8(i) = qp8_1(1);               	ang_qp8(i) = 50 - qpa_1(1) ;
            end
            
            if qp10_0(1) >= qp10_1(1),
                qp10(i) = qp10_0(1);              	ang_qp10(i) = 31 + qpa_0(1) ;
            else
                qp10(i) = qp10_1(1);               	ang_qp10(i) = 41 - qpa_1(1) ;
            end
            
            ang2(i) = 49 + ang0_2 ;
        end
 	    max_tt = max(tt(:)); 			             N = find(tt == max_tt(1)) ;
	    max_sl = max(sl_1(:));			        N_sl = find(sl_1 == max_sl) ;
        max_qp = max(qp(:));			        N_qp = find(qp == max_qp) ;
        max_qp8 = max(qp8(:));			     N_qp8 = find(qp8 == max_qp8) ;
        max_qp10 = max(qp10(:));		   N_qp10 = find(qp10 == max_qp10) ;
        max_hex = max(hex(:));                 N_hex = find(hex == max_hex(1));

        tt_out(Phi5+1) = max_tt(1);                  ang_tt_out(Phi5+1) = ang1(N(1)) ;
	    sl_out(Phi5+1) = max_sl(1);		           ang_sl_out(Phi5+1) = ang_sl(N_sl(1)) ;
	    qp_out(Phi5+1) = max_qp(1);		        ang_qp_out(Phi5+1) = ang_qp(N_qp(1)) ;
        qp8_out(Phi5+1) = max_qp8(1);		  ang_qp8_out(Phi5+1) = ang_qp8(N_qp8(1)) ;
        qp10_out(Phi5+1) = max_qp10(1);	   ang_qp10_out(Phi5+1) = ang_qp10(N_qp10(1)) ;
        hex_out(Phi5+1) = max_hex(1);          ang_hex_out(Phi5+1) = ang2(N_hex(1));
        %hex,ang2
    end
end ;   end ;   end ;   end


