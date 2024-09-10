% Matched filter for DCE + Median Filter 
% a_1 = Matched_Filter_uCSR_20190401(a_0, a_thresh)

function a_1 = Matched_Filter_uCSR_20190401(a_0, a_thresh)



s_0 = size(a_0);
temp = reshape( a_0, [s_0(1)*s_0(2), s_0(3)] );
Sig_S_Mean = mean(temp);
Sig_T_Mean = mean( temp, 2 );

% Remove Temporal mean and calculate the tmporal std
Sig_AC = temp - Sig_T_Mean*ones(1, s_0(3));
Sig_AC_std = std(Sig_AC, 0, 2);
Sig_S_Mean_std = std(Sig_S_Mean);

% Calculate correlation:
Sig_Corr = reshape((Sig_AC*Sig_S_Mean')./Sig_AC_std/Sig_S_Mean_std, [s_0(1), s_0(2)])/s_0(3);

% figure(1), subplot(2,2,1), imagesc(real(Sig_Corr)), axis image, colorbar
% figure(1), subplot(2,2,2), imagesc(real(Sig_Corr)>0.5), axis image, colorbar
% figure(2), hist(real(Sig_Corr(:)), 100)

% whos
% sum(Sig_Corr(:) > 0.5)/s_0(1)/s_0(2)

Corr_Thresh = a_thresh;
Corr_Mask = bwmorph(Sig_Corr > Corr_Thresh, 'clean');
Corr_Mask = bwmorph(Corr_Mask, 'close');
se = strel('line',3,3);
Corr_Mask = imdilate(Corr_Mask,se);
% figure(1), subplot(2,2,3), imagesc(Corr_Mask), axis image, colorbar

Sig_AC_Match_Filtered = Sig_AC.*(reshape(Corr_Mask, [s_0(1)*s_0(2), 1] )*ones(1, s_0(3)));

Img_Match_Filtered = reshape(Sig_T_Mean*ones(1, s_0(3)) + Sig_AC_Match_Filtered, [s_0(1), s_0(2), s_0(3)]);

% for j=1:10
%     for i=1:9
%         figure(2), imagesc(abs([a_0(end:-1:1,:,i), Img_Match_Filtered(end:-1:1,:,i)])), axis image, colormap(gray), title(num2str(i)), pause(0.1),
%     end
% end

% Apply temporal median filter
Img_AC = reshape(Sig_AC, [s_0(1), s_0(2), s_0(3)]);
% Img_AC_Match_Filtered = reshape(Sig_AC_Match_Filtered, [s_0(1), s_0(2), s_0(3)]);
Img_AC_Med_Filtered = Img_AC;
Img_Match_Med_Filtered = abs(Img_Match_Filtered);
tic
for i=1:s_0(1)
    for j=1:s_0(2) 
        for k=2:s_0(3)-1
            temp = Img_AC(i,j,k-1:k+1);
            Img_AC_Med_Filtered(i,j,k) = median(temp(:));
            temp = abs(Img_Match_Filtered(i,j,k-1:k+1));
            Img_Match_Med_Filtered(i,j,k) = median(temp(:));             
        end
    end
end
toc

a_1 = Img_Match_Med_Filtered;






