% function [tt_out,ang_tt_out, qp_out,ang_qp_out,sl_out,ang_sl_out,hex_out,hex_ang] = find_ang_corr(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)
% f = 80 Hz k = 20; f=90Hz, k0 = 22;
function [tt_out,ang_tt_out, square_out,ang_square_out] = find_ang_corr(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)

ang1 = 0;
for A2 = a2:10:a2f
for Phi2=p2:10:p2f;
    ang1 = ang1+1; ang2 =0;phi=0;
for Phi5=p5:10:p5f;
    phi=phi+1; ang2 = ang2 + 1;
for A4=a4:100:a4f
    n4 = A4/100; qp_8=0;    qp_12=0; n5=0;
    for A5_0 = a5:10:a5f
        A5 = round(A5_0*100);
        n5 = A5_0/10;
        fname = sprintf('%i_%i_%i_%i_%i',A4,A5_0,Phi5,A2,Phi2),
        a0 = readin_160_120_file(fname);
        i00 = size(a0),
        a0 = reshape_128_128_112103(a0);
        for i=1:i00(3)
            pause(0.01)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))) ;
            a = xy2rt(afft(:,:,i),65,65,1:50,0:pi/180:2*pi-0.001) ; %a(:,1:3)=0;imagesc(a), pause
            e = sum(a(:,k0-2:k0+2),2);          e = e - mean(e(:)) ;                    % plot(e), pause(5)
            e = my_xcorr(e,e);                  emin = min(e(:)) ;                      emax = max(e(:)) ;
            peak0 = e(11:51);                   peak1 = e(311:351) ;     	            peak2 = e(51:71) ;
	        peak_qp0 = e(87:95);		        peak_qp1 = e(267:275) ;
            [tt_0,ang_0] = findpeakval(peak0);  [tt_1,ang_1] = findpeakval(peak1) ;     [hex(i),ang0_2] = findpeakval(peak2) ;
	        [qp_0,qpa_0] =findpeakval(peak_qp0);[qp_1,qpa_1] =findpeakval(peak_qp1);

            if tt_0(1) >= tt_1(1),
                tt(i) = tt_0(1);               	ang1(i) = 9 + ang_0(1) ;
            else
                tt(i) = tt_1(1);               	ang1(i) = 51 - ang_1(1) ;
            end

            if qp_0(1) >= qp_1(1),
                qp(i) = qp_0(1);              	ang_qp(i) = 40 + qpa_0(1) ;
            else
                qp(i) = qp_1(1);               	ang_qp(i) = 50 - qpa_1(1) ;
            end

            ang2(i) = 49 + ang0_2 ;
        end
        
 	    max_tt = max(tt(:)); 			N = find(tt == max_tt(1)) ;
        max_qp = max(qp(:));			N_qp = find(qp == max_qp) ;
        max_hex = max(hex(:));          N_hex = find(hex == max_hex(1));

        tt_out(n4,n5) = max_tt(1);      ang_tt_out(n4,n5) = ang1(N(1)) ;
	    square_out(n4,n5) = max_qp(1);	ang_square_out(n4,n5) = ang_qp(N_qp(1)) ;
        hex_out(n4,n5) = max_hex(1);    ang_hex_out(n4,n5) = ang2(N_hex(1));
        %hex,ang2
    end
end ;   end ;   end ;   end


