
% Sum of Square image reconstruction
% function Img = SoS(K_space, Sensitivity_Masks, crop)


function Img = SoS_20141209(K_space, Sensitivity_Masks, crop)

Img = 0;
s = size(K_space);
if length(s) == 2, s(3) = 1; end
if length(s) ~=3
    'Error! The input data must be 3-D k-space data!'
    return,
end
Img = zeros( s(1), s(2) );
if nargin == 1
    for z_index=1:s(3)
        %ima = abs(ifftshift(ifft2(ifftshift(K_space(:, :, z_index)))));
        ima = abs((ifft2((K_space(:, :, z_index))))); % 2014-12-09
        Img = Img + ima .^ 2;
    end
    crop = 1;
    Img = sqrt(Img);
elseif nargin == 2
    Scaling = sqrt(sum( abs(Sensitivity_Masks).^2, 3 ));
    Scaling_inv = zeros(size(Scaling));
    Scaling_inv(find(Scaling > 0)) = 1./Scaling(find(Scaling > 0)) ;
    for z_index=1:s(3)
        %ima = abs((ifft2(ifftshift(K_space(:, :, z_index))))).*Sensitivity_Masks(:,:,z_index);
        ima = abs(ifftshift(ifft2(ifftshift(K_space(:, :, z_index))))).*Sensitivity_Masks(:,:,z_index);
        Img = Img + abs(ima).*Scaling_inv;
        
        %         temp = (ifftshift(ifft2(ifftshift(K_space(:, :, z_index)))));
        %         noise = temp.*(1-Sensitivity_Masks(:,:,z_index)); %imagesc(abs(noise)), axis image, colorbar, pause,
        %         noise_std = sqrt( sum(abs(noise(:)).^2)/(sum(sum((1-Sensitivity_Masks(:,:,z_index))))) /2 );
        %         ima = shrinkage(temp, noise_std).*Sensitivity_Masks(:,:,z_index) ;
        %         Img = Img + abs(temp.*conj(ima));
    end
    crop = 1;
elseif nargin == 3
    Scaling = sum( abs(Sensitivity_Masks).^2, 3 );
    Scaling_inv = zeros(size(Scaling));
    Scaling_inv(find(Scaling > 0)) = 1./Scaling(find(Scaling > 0)) ;
    for z_index=1:s(3)
        ima = abs(ifftshift(ifft2(ifftshift(K_space(:, :, z_index))))).*Sensitivity_Masks(:,:,z_index);
        %ima = abs(ifftshift(ifft2(ifftshift(K_space(:, :, z_index)))));
        Img = Img + abs(ima).*Scaling_inv;
    end
end
if crop % crop half of the FE direction
    Img = Img(s(1)/4+1:s(1)*3/4,:); 
else
    Img = Img;
end






