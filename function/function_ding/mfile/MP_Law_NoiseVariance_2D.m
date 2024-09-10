
function [Cutoff, Variance, bestM, bestN, bestDm, bestDn] = MP_Law_NoiseVariance_2D(data,m,n,dm,dn)
% This is a function to estimate the noise variance in 2D image using the MP Law.
% [Cutoff, Variance] = MP_Law_NoiseVariance_2D(data,m,n,dm,dn);
% data: original data matrix
% m,n: the size of the subimage
% dm, dn: the step size of the sliding window

bestVar = 0.0;
bestPP = 0;
bestQQ = 0;        
for qq=1:numel(m)
    for pp=1:numel(dm)
        disp(num2str([m(qq), n(qq), dm(pp), dn(pp)]))
        % [Cutoff, Variance] = MP_Law_NoiseVariance_2D(data, m(qq), n(qq), dm(pp), dn(pp));
        
        %% does the real job ...
        data = double(data);
        c = sliding_im2col(data, m(qq), n(qq), dm(pp), dn(pp)); 
        cs=size(c); 
        c=c-mean(c(:)); 
        [V,D] = eig(c*c'/cs(2)); 
        E = diag(D); %figure(4), hist(E(1:1000), 24)
        [Cutoff, Variance, ks, beta, p_value, H] = KS_Cutoff_2Steps( E, cs(2));
        Variance        
        
        if ( Variance > bestVar )
            bestVar = Variance;
            bestPP = pp;
            bestQQ = qq;
        end
    end
end

bestM = m(bestQQ);
bestN = n(bestQQ);
bestDm = dm(bestPP);
bestDn = dn(bestPP);
Variance = bestVar;

disp([num2str([m(bestQQ), n(bestQQ), dm(bestPP), dn(bestPP)]) ' -- ' num2str(bestVar)])
