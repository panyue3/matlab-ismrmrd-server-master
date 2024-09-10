% Find the noise in the ROI, the images used are the subtraction between
% adjacent images.

function noise = Noise_Subtraction_ROI(a, mask)

s = size(a);

for i=1:s(3)-1
    t = a(:,:,i)-a(:,:,i+1);
%    t_roi = t(find(mask==1));
    t_roi = t(1:40,:);
    t_std(i) = std(t_roi(:));
end

noise = mean(t_std);








