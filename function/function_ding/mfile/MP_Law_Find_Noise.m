function [ Noise ] = Raw_Data_Noise( a_0 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Noise = 0;
s_0 = size(a_0);

if length(s_0) < 3
    disp('Input MUST be 3-D or 4-D Array!')
    return
elseif length(s_0) > 4
    disp('Input MUST be 3-D or 4-D Array!')
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
if length(s_0) == 3
    Noise = reshape( Noise, s_0(1), s_0(2),  );


end

