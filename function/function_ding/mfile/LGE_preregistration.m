
function a_r = LGE_preregistration(a_0)

shiftRange =-5:5;
N_sw = 6;
s_0 = size(a_0);
[x, y] = meshgrid(1:s_0(2), 1:s_0(1));

r_0 = min([s_0(1:2)])/8;
r = ((x-s_0(2)/2).^2 + (y-s_0(1)/2).^2).^0.5;
mask_0 = r>r_0;
mask_r = exp(-(r-r_0).^2/200).*mask_0 + (1-mask_0);
%mask_t = zeros(s_0(1), s_0(2)); mask_t(s_0(1)/4+[1:s_0(1)/2], s_0(2)/4+[1:s_0(2)/2]) = 0.2;
%figure(1), imagesc([mask_0, mask_r, mask_t+mask_r]), axis image

w_0 = ones(N_sw, 1);
switch N_sw
    case 8
        w_0 = [0.7, 0.8, 0.9, 1, 1, 0.9, 0.8, 0.7];
    case 6
        w_0 = [ 0.8, 0.9, 1, 1, 0.9, 0.8];
end


d = [];
Counter = 0;
for i=shiftRange
    for j=shiftRange
        Counter = Counter + 1;
        d(Counter,:) = [i, j];
    end
end

if ndims(a_0) == 3
    num_slices = s_0(3);
    a_f = a_0(:,:,[ones(1, N_sw/2), 1:s_0(3), s_0(3)*ones(1, N_sw/2)]);    
    L1 = [];
    
    weightingMask = repmat(mask_r, [1,1,N_sw]);
    for i=1:N_sw
        weightingMask(:,:,i) = mask_r*w_0(i);
    end

    % Function to compute L1 norm of finite differences
    computeL1Norm = @(img1, img2) sum(((weightingMask(:) .* abs(img1(:) - img2(:)))));
    % computeL2Norm = @(img1, img2) sum(abs(weightingMask(:) .* (img1(:) -
    % img2(:))).^2); 
    
    % Align images using sliding window in slie direction and L1 norm
    a_f_r = a_f;
    for i=1+N_sw/2:num_slices+N_sw/2
        a_sw = a_f(:,:,i+[-N_sw/2:-1,1:N_sw/2]);
        a_sw = a_sw - mean(a_sw(:));
        %     for k=1:size(a_sw, 3)
        %         temp = a_sw(:,:,k);
        %         a_sw(:,:,k) = (temp - mean(temp(:)))/std(temp(:));
        %     end
        Imoving = repmat(a_f(:,:,i), [1,1,N_sw]);
        Imoving = Imoving - mean(Imoving(:));
        %     Imoving = (Imoving - mean(Imoving(:)))/std(Imoving(:));
        L1 = zeros(size(d,1), 1);
        %size(a_sw)
        %size(Imoving)
        for j=1:size(d,1)
            L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
        end
        J = find(L1==min(L1));
        D_0 = d(J(1),:);
        %disp(d(J,:))
        a_f_r(:,:,i) = circshift(a_f(:,:,i), D_0);
        a_f(:,:,i) = a_f_r(:,:,i); % Recursive filtering 20240814
        if i==1+N_sw/2
            for j=1:N_sw/2
                a_f(:,:,j) = a_f(:,:,i);
            end
        end
        if i==num_slices+N_sw/2
            for j=num_slices+N_sw/2+[1:N_sw/2]
                a_f(:,:,j) = a_f(:,:,i);
            end
        end
    end
    % Second Iteration
    a_f = a_f_r(:,:,[(N_sw/2+1)*ones(1, N_sw/2), N_sw/2+1:N_sw/2+s_0(3), (N_sw/2+s_0(3))*ones(1, N_sw/2)]);
    for i=1+N_sw/2:num_slices+N_sw/2
        a_sw = a_f(:,:,i+[-N_sw/2:-1,1:N_sw/2]);
        a_sw = a_sw - mean(a_sw(:));
        %     for k=1:size(a_sw, 3)
        %         temp = a_sw(:,:,k);
        %         a_sw(:,:,k) = (temp - mean(temp(:)))/std(temp(:));
        %     end
        Imoving = repmat(a_f(:,:,i), [1,1,N_sw]);
        Imoving = Imoving - mean(Imoving(:));
        %     Imoving = (Imoving - mean(Imoving(:)))/std(Imoving(:));
        L1 = zeros(size(d,1), 1);
        for j=1:size(d,1)
            L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
        end
        J = find(L1==min(L1));
        D_0 = d(J(1),:);
        %disp(d(J,:))
        a_f_r(:,:,i) = circshift(a_f(:,:,i), D_0);
        a_f(:,:,i) = a_f_r(:,:,i); % Recursive filtering 20240814
        if i==1+N_sw/2
            for j=1:N_sw/2
                a_f(:,:,j) = a_f(:,:,i);
            end
        end
        if i==num_slices+N_sw/2
            for j=num_slices+N_sw/2+[1:N_sw/2]
                a_f(:,:,j) = a_f(:,:,i);
            end
        end
    end
    a_r = a_f_r(:,:,N_sw/2+1:N_sw/2+s_0(3));

elseif ndims(a_0) == 4
    num_s1 = s_0(3);
    num_s2 = s_0(4);
    a_f = a_0(:,:,[ones(1, N_sw/2), 1:s_0(3), s_0(3)*ones(1, N_sw/2)],[ones(1, N_sw/2), 1:s_0(4), s_0(4)*ones(1, N_sw/2)]);    
    L1 = [];
    
    weightingMask = repmat(mask_r, [1,1,N_sw,N_sw]);
    for i=1:N_sw
        for j=1:N_sw
            weightingMask(:,:,i,j) = mask_r*w_0(i)*w_0(j);
        end
    end

    % Function to compute L1 norm of finite differences
    computeL1Norm = @(img1, img2) sum(((weightingMask(:) .* abs(img1(:) - img2(:)))));
    % computeL2Norm = @(img1, img2) sum(abs(weightingMask(:) .* (img1(:) -
    % img2(:))).^2); 
    
    % Align images using sliding window in slie direction and L1 norm
    a_f_r = a_f;
    for i=1+N_sw/2:num_s1+N_sw/2
        for i2 = 1+N_sw/2:num_s2+N_sw/2
            a_sw = a_f(:,:,i+[-N_sw/2:-1,1:N_sw/2],i2+[-N_sw/2:-1,1:N_sw/2]);
            a_sw = a_sw - mean(a_sw(:));

            Imoving = repmat(a_f(:,:,i,i2), [1,1,N_sw,N_sw]);
            Imoving = Imoving - mean(Imoving(:));
            %     Imoving = (Imoving - mean(Imoving(:)))/std(Imoving(:));
            L1 = zeros(size(d,1), 1);

            for j=1:size(d,1)
                L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
            end
            J = find(L1==min(L1));
            D_0 = d(J(1),:);
            %disp(d(J,:))
            a_f_r(:,:,i,i2) = circshift(a_f(:,:,i,i2), D_0);
            a_f(:,:,i,i2) = a_f_r(:,:,i,i2); % Recursive filtering 20240814
            if i2==1+N_sw/2
                for j=1:N_sw/2
                    a_f(:,:,i,j) = a_f(:,:,i,i2);
                end
            end
            if i2==num_s1+N_sw/2
                for j=num_s1+N_sw/2+[1:N_sw/2]
                    a_f(:,:,i,j) = a_f(:,:,i,i2);
                end
            end
        end
        if i==1+N_sw/2
            for j=1:N_sw/2
                a_f(:,:,j,:) = a_f(:,:,i,:);
            end
        end
        if i==num_s1+N_sw/2
            for j=num_s1+N_sw/2+[1:N_sw/2]
                a_f(:,:,j,:) = a_f(:,:,i,:);
            end
        end
    end
    % Second Iteration
    a_f = a_f_r(:,:,[(N_sw/2+1)*ones(1, N_sw/2), N_sw/2+1:N_sw/2+s_0(3), (N_sw/2+s_0(3))*ones(1, N_sw/2)],[(N_sw/2+1)*ones(1, N_sw/2), N_sw/2+1:N_sw/2+s_0(4), (N_sw/2+s_0(4))*ones(1, N_sw/2)]);
    for i=1+N_sw/2:num_s1+N_sw/2
        for i2 = 1+N_sw/2:num_s2+N_sw/2
            a_sw = a_f(:,:,i+[-N_sw/2:-1,1:N_sw/2],i2+[-N_sw/2:-1,1:N_sw/2]);
            a_sw = a_sw - mean(a_sw(:));

            Imoving = repmat(a_f(:,:,i,i2), [1,1,N_sw,N_sw]);
            Imoving = Imoving - mean(Imoving(:));
            %     Imoving = (Imoving - mean(Imoving(:)))/std(Imoving(:));
            L1 = zeros(size(d,1), 1);

            for j=1:size(d,1)
                L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
            end
            J = find(L1==min(L1));
            D_0 = d(J(1),:);
            %disp(d(J,:))
            a_f_r(:,:,i,i2) = circshift(a_f(:,:,i,i2), D_0);
            a_f(:,:,i,i2) = a_f_r(:,:,i,i2); % Recursive filtering 20240814
            if i2==1+N_sw/2
                for j=1:N_sw/2
                    a_f(:,:,i,j) = a_f(:,:,i,i2);
                end
            end
            if i2==num_s1+N_sw/2
                for j=num_s1+N_sw/2+[1:N_sw/2]
                    a_f(:,:,i,j) = a_f(:,:,i,i2);
                end
            end
        end
        if i==1+N_sw/2
            for j=1:N_sw/2
                a_f(:,:,j,:) = a_f(:,:,i,:);
            end
        end
        if i==num_s1+N_sw/2
            for j=num_s1+N_sw/2+[1:N_sw/2]
                a_f(:,:,j,:) = a_f(:,:,i,:);
            end
        end
    end
    a_r = a_f_r(:,:,N_sw/2+1:N_sw/2+s_0(3),N_sw/2+1:N_sw/2+s_0(4));
else
    disp('Error! Size of Input Array Must be 3D or 4D!')
end

return


% % Third Iteration
% a_f = a_f_r(:,:,[(N_sw/2+1)*ones(1, N_sw/2), N_sw/2+1:N_sw/2+s_0(3), (N_sw/2+s_0(3))*ones(1, N_sw/2)]);
% for i=1+N_sw/2:num_slices+N_sw/2
%     a_sw = a_f(:,:,i+[-N_sw/2:-1,1:N_sw/2]);
%     a_sw = a_sw - mean(a_sw(:));
% %     for k=1:size(a_sw, 3)
% %         temp = a_sw(:,:,k);
% %         a_sw(:,:,k) = (temp - mean(temp(:)))/std(temp(:));
% %     end
%     Imoving = repmat(a_f(:,:,i), [1,1,N_sw]);
%     Imoving = Imoving - mean(Imoving(:));
% %     Imoving = (Imoving - mean(Imoving(:)))/std(Imoving(:));
%     L1 = zeros(size(d,1), 1);
%     for j=1:size(d,1)
%         L1(j) = computeL1Norm(a_sw, circshift(Imoving, d(j,:)));
%     end
%     J = find(L1==min(L1));    
%     D_0 = d(J(1),:);
%     %disp(d(J,:))
%     a_f_r(:,:,i) = circshift(a_f(:,:,i), D_0);
%     a_f(:,:,i) = a_f_r(:,:,i); % Ding 20240814 Recursive Applying filter
%     if i==1+N_sw/2 
%         for j=1:N_sw/2
%             a_f(:,:,j) = a_f(:,:,i);
%         end
%     end
%     if i==num_slices+N_sw/2 
%         for j=num_slices+N_sw/2+[1:N_sw/2]
%             a_f(:,:,j) = a_f(:,:,i);
%         end
%     end
% end

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





