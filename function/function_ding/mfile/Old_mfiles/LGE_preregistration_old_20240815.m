
function a_r = LGE_preregistration(a_0)

shiftRange =-5:5;
s_0 = size(a_0);
num_slices = s_0(3);
a_f = a_0;
d = [];
L1 = [];

[x, y] = meshgrid(1:s_0(2), 1:s_0(1));

r_0 = min([s_0(1:2)])/8;
r = ((x-s_0(2)/2).^2 + (y-s_0(1)/2).^2).^0.5;
mask_0 = r>r_0; 
mask_r = exp(-(r-r_0).^2/200).*mask_0 + (1-mask_0); 
%mask_t = zeros(s_0(1), s_0(2)); mask_t(s_0(1)/4+[1:s_0(1)/2], s_0(2)/4+[1:s_0(2)/2]) = 0.2;
%figure(1), imagesc([mask_0, mask_r, mask_t+mask_r]), axis image

% Gaussian Filter data 
% for i = 1:s_0(3) 
%     a_f(:,:,i) = imgaussfilt(a_0(:,:,i),1.0);
%     % figure(1), imagesc([a_0(:,:,i).*mask_r, a_f(:,:,i).*mask_r]), axis image, colormap("gray"), pause,
% end

weightingMask = repmat(mask_r, [1,1,4]);
% Function to compute L1 norm of finite differences
computeL1Norm = @(img1, img2) sum(sum(sum(weightingMask .* abs(img1 - img2))));

% Align images using sliding window in slie direction and L1 norm 
Counter = 0;
for i=shiftRange
    for j=shiftRange
        Counter = Counter + 1;
        d(Counter,:) = [i, j];
    end
end 

a_f_r = a_f;
for i=3:num_slices-2
    a_sw = a_f(:,:,i+[-2,-1,1,2]);
    a_sw = a_sw - mean(a_sw(:));
    Imoving = repmat(a_f(:,:,i), [1,1,4]); 
    Imoving = Imoving - mean(Imoving(:));
    L1 = zeros(size(d,1), 1);
    for j=1:size(d,1)
        L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
    end
    J = find(L1==min(L1));
    %disp(d(J,:))
    a_f_r(:,:,i) = circshift(a_f(:,:,i), d(J(1),:));
end
a_f = a_f_r;
for i=3:num_slices-2
    a_sw = a_f(:,:,i+[-2,-1,1,2]);
    a_sw = a_sw - mean(a_sw(:));
    Imoving = repmat(a_f(:,:,i), [1,1,4]); 
    Imoving = Imoving - mean(Imoving(:));
    L1 = zeros(size(d,1), 1);
    for j=1:size(d,1)
        L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
    end
    J = find(L1==min(L1));
    %disp(d(J,:))
    a_f_r(:,:,i) = circshift(a_f(:,:,i), d(J(1),:));
end
a_r = a_f_r;
% for j=1:10
% for i=1:num_slices
%     figure(1), imagesc([a_0(s_0(1)/4+[16:s_0(1)/2-15],s_0(2)/4+[1:s_0(2)/2],i)-a_f_r(s_0(1)/4+[16:s_0(1)/2-15],s_0(2)/4+[1:s_0(2)/2],i)]), axis image, pause(0.1)
% end
% end
% 
% for i=1:num_slices
%     figure(1), imagesc([a_0(s_0(1)/4+[16:s_0(1)/2-15],s_0(2)/4+[1:s_0(2)/2],i);a_f_r(s_0(1)/4+[16:s_0(1)/2-15],s_0(2)/4+[1:s_0(2)/2],i)]), axis image, grid on, pause
% end

% test code:
% i = 25;
% a_sw = a_f(:,:,i+[-2,-1,1,2]);
% a_sw = a_sw - mean(a_sw(:));
% Imoving = repmat(a_f(:,:,i), [1,1,4]);
% Imoving = Imoving - mean(Imoving(:));
% 
% for j = 1:size(d,1)
%     I_diff = abs(a_sw-circshift(Imoving, d(j,:)));
% 
%     L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
% end









% 
% for i = Cen_SL+1:num_slices-2
%     Imoving = a_f(:,:,i);
%     Bx = zeros(s_0(1), s_0(2), N_sw);
%     By = Bx; Fx = Bx; Fy = Bx;
%     a_sw = a_f(:,:,i+[1:N_sw]-(N_sw+1)/2);
%     %clock,
%     parfor j=1:N_sw
%         Istatic = a_sw(:,:,j);
%         [Ireg,Bx(:,:,j), By(:,:,j), Fx(:,:,j), Fy(:,:,j)] = register_images(Imoving, Istatic, Options);
%     end
%     %clock,
%     %pause
%     LGE_img_register(:,:,i) = movepixels( Imoving, mean(Bx,3), mean(By,3));
%     LGE_img_register_median(:,:,i) = movepixels( Imoving, median(Bx,3), median(By,3));
% end
% 
% for i = Cen_SL:-1:3
%     Imoving = a_f(:,:,i);
%     Bx = zeros(s_0(1), s_0(2), N_sw);
%     By = Bx; Fx = Bx; Fy = Bx;
%     a_sw = a_f(:,:,i+[1:N_sw]-(N_sw+1)/2);
%     parfor j=1:N_sw
%         Istatic = a_sw(:,:,j);
%         [Ireg,Bx(:,:,j), By(:,:,j), Fx(:,:,j), Fy(:,:,j)] = register_images(Imoving, Istatic, Options);
%     end
% 
%     LGE_img_register(:,:,i) = movepixels( Imoving, mean(Bx,3), mean(By,3));
%     LGE_img_register_median(:,:,i) = movepixels( Imoving, median(Bx,3), median(By,3));
% end





