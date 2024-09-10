%   This is to get the noise covariance matrix from raw data set directly
%   To get the Noise Cov without a noise scan.
%   function [Cov, p_value] = Raw_Data_Cov(a_0)
%   a_0: 5-D raw data, come from Reshape_RawData(Data, asc);
%   If p_value < 0.9, the result is not good.


function [Cov, p_value] = Raw_Data_Cov(a_0)

s1 = size(a_0);

if length(s1) ==5
    N_1 = sqrt(squeeze(sum(abs(a_0(:,:,1,:,:)).^2, 5)));
    [a_I_1, V_1, D_1] = KL_Eigenimage(N_1); E_1 = diag(D_1);
    [Cutoff_1, Var_1, ks, beta, p_value, H] = KS_Cutoff_2Steps(E_1, s1(1)*s1(2) );
    Noise_1 = permute(a_0, [1,2,3,5,4] ) ;
    Noise_1 = reshape( Noise_1, s1(1)*s1(2)*s1(5), s1(4)) ;
    True_N_1 = reshape( Noise_1*V_1(:,1:Cutoff_1), s1(1)*s1(2), s1(5), Cutoff_1 );
    True_N_1 = permute( True_N_1, [1,3,2] );
    True_N_1 = reshape( True_N_1, s1(1)*s1(2)*Cutoff_1, s1(5) );
    Cov = (True_N_1'*True_N_1 + (True_N_1'*True_N_1)')/2/(s1(1)*s1(2)*Cutoff_1) ;
    
elseif length(s1) ==4
    N_1 = sqrt(squeeze(sum(abs(a_0).^2, 4)));
    [a_I_1, V_1, D_1] = KL_Eigenimage(N_1); E_1 = diag(D_1); %size(V_1)
    [Cutoff_1, Var_1, ks, beta, p_value, H] = KS_Cutoff_2Steps(E_1, s1(1)*s1(2) );
    Noise_1 = permute(a_0, [1,2,4,3] ) ;
    Noise_1 = reshape( Noise_1, s1(1)*s1(2)*s1(4), s1(3)) ;
    Noise_1 = Noise_1*V_1(:,1:Cutoff_1);
    Noise_1 = reshape( Noise_1, s1(1), s1(2), s1(4), Cutoff_1) ;
    True_N_1 = permute( Noise_1, [1,2,4,3] );
    True_N_1 = reshape( True_N_1, s1(1)*s1(2)*Cutoff_1, s1(4) );
    Cov = (True_N_1'*True_N_1 + (True_N_1'*True_N_1)')/2/(s1(1)*s1(2)*Cutoff_1) ;

else
    'Bad Raw Data Type'
end



