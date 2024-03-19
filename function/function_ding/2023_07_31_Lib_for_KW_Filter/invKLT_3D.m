

function a_r = invKLT_3D(a_I, V)

% a_r = invKLT_3D(a_I, V)
% a_I  : Eigenimages
% V    : Eigenvector matrix of KLT.
% V is from the following KLT script.
% [a_I, V, D] = KL_Eigenimage(a_0);
% 

% Yu Ding 2011-07-14

s = size(a_I);
a_r = zeros(s);
if length(s)~=3
    disp('Error! The input a_I must be a 3-D array!');
    return
end

b = (reshape(a_I, [s(1)*s(2),s(3)] ));
a_r = (reshape(b*V', [s(1),s(2),s(3)] ) ) ;


