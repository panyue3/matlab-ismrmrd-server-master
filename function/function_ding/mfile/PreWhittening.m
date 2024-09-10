% Calculate the pre-whittened data
% function Data = PreWhittening( Data, Psi );

function Data = PreWhittening( Data, Psi );

S0 = size(Data);
S1 = size(Psi);

if S1(1)~=S0(end),
    'Error! Noise Cov Matrix size does not match Data Matrix!';
    return,
elseif length(S1)~=2
    'Error! Incorrect Noise Cov Matrix !';
    return,
elseif S1(1) ~= S1(2)
    'Error! Incorrect Noise Cov Matrix size!';
    return,
end

[V, D] = eig( (Psi+Psi')/2 ); % Eigen-decomposition
E = diag(1./sqrt(diag(D))); 
Psi_inv_sqrt = V*E*V'; % Matrix: Psi^(-1/2)

if prod(S0)==sum(S0)-1 % 1 D data set
    'Error! Data is 1-D !'
    return
elseif length(S0) == 2 % 2-D Data
    Data = Data*Psi_inv_sqrt; % whittening
elseif length(S0) == 3 % 3-D Data
    temp = reshape( Data, S0(1)*S0(2), S0(3) );
    temp = temp*Psi_inv_sqrt; % whittening
    Data = reshape( temp, S0(1), S0(2), S0(3) );
elseif length(S0) == 4 % 4-D Data
    temp = reshape( Data, prod(S0(1:3)), S0(4) );
    temp = temp*Psi_inv_sqrt; % whittening
    Data = reshape( temp, S0(1), S0(2), S0(3), S0(4) );
elseif length(S0) == 5 % 5-D Data
    temp = reshape( Data, prod(S0(1:4)), S0(5) );
    temp = temp*Psi_inv_sqrt; % whittening
    Data = reshape( temp, S0(1), S0(2), S0(3), S0(4), s0(5) );
else
    'Can not handle Data dimension ! '
    return
end
    











