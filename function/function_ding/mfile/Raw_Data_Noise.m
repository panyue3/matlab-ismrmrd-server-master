function [ Noise, Cutoff, p_value ] = Raw_Data_Noise( a_0 )
%[ Noise, Cutoff, p_value ] = Raw_Data_Noise( a_0 )
%   a_0: 4-D Raw Data
%   Noise:  Output noise level, 2-D matrix, 2nd Dim is the channel number
%   Cutoff: MP-law fitting Cutoff 
%   p_value: MP-law fitting p_value
Noise = 0;
s_0 = size(a_0);

if length(s_0) ~= 4
    disp('Input MUST be 4-D Array!')
    return
end

% reshape it to a 2-D matrix
a_temp = reshape( a_0, prod(s_0(1:end-1)), s_0(end) );
s = size(a_temp);

% Solve the eigen problem
A = (a_temp'*a_temp)/(s(1)); %clear b;
[V,D] = (eig((A+A')/2));
a_I = a_temp*V;
E = diag(D); %figure(4), hist(E, 24)

% KS cutoff using MP-law
[Cutoff, Variance, ks, beta, p_value, H] = KS_Cutoff_2Steps(E, s(1));

Noise = a_I(:, 1:Cutoff);
Noise = reshape( Noise, s_0(1), s_0(2), s_0(3), Cutoff );
Noise = permute( Noise, [1, 2, 4, 3]);
Noise = reshape( Noise, s_0(1)*s_0(2)*Cutoff, s_0(3) );

end

