% function [tt_out,ang_tt_out, qp_out,ang_qp_out,sl_out,ang_sl_out,hex_out,hex_ang] = find_ang_corr(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)
% f = 80 Hz k = 20; f=90Hz, k0 = 22;
function qp_diff = find_qp_corr_a2_a4(a2,a2f,p2,p2f,a4,a4f,a5,a5f,p5,p5f,k0)

ang1 = 0; a2 =0;
for A2 = a2:5:a2f
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
        onset_0 = 0;
        for i=1:i00(3)
            afft(1:128,1:128,i) = abs(fftshift(fft2(a0(:,:,i)))) ;
            a = xy2rt(afft(:,:,i),65,65,1:50,pi/360:pi/180:2*pi) ;
            e = sum(a(:,k0-2:k0+2),2); e0 = e;   
             
            p0(1:360) = e0(1:360); p0(361:450) = e0(1:90);
            max_e = find(e0 ==max(e0(:)) );
            m_e = mod(max_e(1),30); if m_e<11, m_e = m_e+30; end, m_e;
            for i0=1:12; b_i = 30*(i0-1)+m_e-10; b_h = 30*(i0)+m_e-10;i0;
                pp_0(i0) = peak1d(p0(b_i:b_h))+b_i-1;        
                if i0>1; a_p(i0-1) = pp_0(i0) -pp_0(i0-1);  end
            end
            a_p(12) = pp_0(1)+360-pp_0(12);
            qp_d(i) = mean(abs(a_p-30));
            
        end
        qp_diff(a2,n4) = min(qp_d);
        
    end
end ;   end ;   end ;   end





