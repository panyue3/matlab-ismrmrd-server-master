% function [tt_out,ang_tt_out, qp_out,ang_qp_out,sl_out,ang_sl_out,hex_out,hex_ang] = find_ang_corr(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)
% f = 80 Hz k = 20; f=90Hz, k0 = 22;
function [tt_out,ang_tt_out,qp_out,ang_qp_out,sl_out,ang_sl_out, hex_out,ang_hex_out] = find_ang_corr_a2_a4(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)

ang1 = 0;% a2 =0;
for A2 = a2:2:a2f
    a2 = a2 + 1 ;
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
        a0 = reshape_128_128_112103(a0); % imagesc(a0(:,:,1)), pause
        
        %sl_1,
 	    max_tt = find_max_average(tt(:),8); 			N = find(tt == max_tt(1)) ;
	    max_sl = find_max_average(sl_1(:),8);			N_sl = find(sl_1 == max_sl) ;
        max_qp = find_max_average(qp(:),8);			N_qp = find(qp == max_qp) ;
        max_hex = find_max_average(hex(:),8);         N_hex = find(hex == max_hex(1));

        tt_out(a2,n4) = max_tt(1);      ang_tt_out(a2,n4) = ang1(N(1)) ;
	    sl_out(a2,n4) = max_sl(1);		ang_sl_out(a2,n4) = ang_sl(N_sl(1)) ;
	    qp_out(a2,n4) = max_qp(1);		ang_qp_out(a2,n4) = ang_qp(N_qp(1)) ;
        hex_out(a2,n4) = max_hex(1);    ang_hex_out(a2,n4) = ang2(N_hex(1));
        %hex,ang2
    end
end ;   end ;   end ;   end


