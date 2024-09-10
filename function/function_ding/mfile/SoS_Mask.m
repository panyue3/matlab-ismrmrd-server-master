
% Sum of Square image reconstruction
% function Img = SoS(K_space, c)


function Img = SoS(K_space, c)

s = size(K_space);
if length(s) == 2, s(3) = 1; end
if length(s) ~=3
    'Error! The input data must be 3-D k-space data!'
    return,
end
Img = zeros( s(1), s(2) );
if nargin == 1
    for z_index=1:s(3)
        ima = abs(ifftshift(ifft2(ifftshift(K_space(:, :, z_index)))));
        Img = Img + ima .^ 2;
    end
elseif nargin == 2
    for z_index=1:s(3)
        ima = abs((ifft2(ifftshift(K_space(:, :, z_index)))));
        Img = Img + ima .^ 2;
    end
end
Img = sqrt(Img(s(1)/4+1:s(1)*3/4,:));






