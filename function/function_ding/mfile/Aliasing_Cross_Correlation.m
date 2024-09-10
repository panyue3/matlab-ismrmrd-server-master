% This is a function to quantify the aliasing artiafcts caused by moving
% fat

% Cro_cor = Aliasing_Cross_Correlation(I_0, perctg )
% I_0: input 3-D image series
% perctg: percenatge of pixels kept in the cov mask

function Cro_cor = Aliasing_Cross_Correlation(I_0, perctg )

s = size(I_0);
Cro_cor = zeros(s(3),s(2));
for i=1:s(3) % loop frame
    temp = I_0(:,:,i);
    I_order = sort(temp(:),'descend');
    mask = temp.*(bwmorph(temp > I_order(round( perctg*s(1)*s(2))),'clean') );% figure(1), imagesc([temp,mask]), pause(0.1),
    Cov_K = [mask, mask];
    Img_T = temp ;
    Scale_f = sqrt(sum(mask(:).^2)*sum(Img_T(:).^2));
    for j=1:s(2), %loop phase encoding direction
        T_cor(j) = sum(sum(Cov_K(:,0+j:s(2)-1+j).*Img_T))/Scale_f ;
    end
    Cro_cor(i,:) = T_cor(:);
end

