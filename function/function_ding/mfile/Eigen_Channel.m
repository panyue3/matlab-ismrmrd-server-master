% Calculate the pre-whittened data
% function Data = Eigen_Channel( Data, Psi );

function [Data, E_0] = Eigen_Channel( Data, Psi )

E_0 = 0;
S0 = size(Data);
S1 = size(Psi);

if S1(1)~=S0(2)& length(S0)==2,
    'Error! Noise Cov Matrix size does not match Data Matrix!',
    return,
elseif S1(1)~=S0(3)
    'Error! Noise Cov Matrix size does not match Data Matrix!',
    return,
elseif length(S1)~=2
    'Error! Incorrect Noise Cov Matrix !',
    return,
elseif S1(1) ~= S1(2)
    'Error! Incorrect Noise Cov Matrix size!',
    return,
end
%'Ha'
[V, D] = eig( (Psi+Psi')/2 ); % Eigen-decomposition
E = diag(1./sqrt(diag(D))); 
Psi_inv_sqrt = V*E*V'; % Matrix: Psi^(-1/2)

if prod(S0)==sum(S0)-1 % 1 D data set
    'Error! Data is 1-D !'
    return
elseif length(S0) == 2 % 2-D Data
    disp('# of Channels = 2')
    Data = Data*Psi_inv_sqrt; % whittening
    %C_0 = Data'*Data/S0(1);
    [a_I, V, D] = KL_Eigenimage(Data);
    Data = a_I;
    E_0 = diag(D);
elseif length(S0) == 3 % 3-D Data
    disp('# of Channels = 3')
    temp = reshape( Data, S0(1)*S0(2), S0(3) );
    temp = temp*Psi_inv_sqrt; % whittening
    [a_I, V, D] = KL_Eigenimage(temp);
    Data = reshape( a_I, S0(1), S0(2), S0(3) );
    E_0 = diag(D);
elseif length(S0) == 4 % 4-D Data
    disp('# of Channels = 4')
    temp = reshape( Data, prod(S0(1:2)), S0(3), S0(4) );
    temp = permute(temp, [1 3 2]);
    temp = reshape(temp, prod([S0(1:2), S0(4)]), S0(3));
    temp = temp*Psi_inv_sqrt; % whittening
    [a_I, V, D] = KL_Eigenimage(temp);
    a_I = reshape( a_I, prod(S0(1:2)), S0(4), S0(3) );
    a_I = permute(a_I, [1 3 2]);
    Data = reshape( a_I, S0(1), S0(2), S0(3), S0(4) ); 
    E_0 = diag(D);
else
    'Can not handle Data dimension ! '
    return
end
    
    
return









