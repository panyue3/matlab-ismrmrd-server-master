
% This is a generic code to get the aliasing score of an image series by
% convoluting with a series of masks.
% function a_c = Aliasing_Score_Mask(Mask, a_0, Acc);
% Mask: mask, should be 3-D
% a_0: input 3-D image series, the first dimension is the FE, second: PE, 
% Acc: acceleration rate
% 2011_01_10

function a_c = Aliasing_Score_Mask(Mask, a_0, Acc);

a_c = 0;
s0 = size(a_0); 
s_m = size(Mask);
if s0(1)~=s_m(1)
    'Mask Size and Image Size do not match!'
    return
elseif s0(1)~=s_m(1)
    'Mask Size and Image Size do not match!'
    return
end

if length(s0) == 3
    a_c = zeros(s0(3), 1);
else
    'error! a_0 is a not an image or image series', 
    return
end

for i=1:s0(3) % loop frame
    mask = Mask(:,:,i) ; %mask = mask - mean(mask(:));
    Cov_K = [mask, mask];
    Img_T = a_0(:,:,i) ;
    Scale_f = sqrt(sum(mask(:).^2)*sum(Img_T(:).^2)); 
    for j=1:s0(2), %loop phase encoding direction
        %size(((Cov_K(:,0+j:s0(2)-1+j))))
        %size(Img_T)
        T_cor(j) = sum(sum(Cov_K(:,0+j:s0(2)-1+j).*Img_T))/Scale_f ;
    end
    Cro_cor(i,:) = T_cor(:); %figure(1), plot(T_cor), title(num2str(i)), pause,
end

for j=1:Acc-1 % loop aliasing points
    D_0 = round(j*(s0(2)+1)/Acc); 
    C_0(1:s0(3), j) = max(Cro_cor(:, D_0-3:D_0+3),[], 2);
end
a_c = max(C_0, [], 2);








