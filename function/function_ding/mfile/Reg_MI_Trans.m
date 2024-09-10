function [s_1, s_2]=im_reg_MI(image1, image2 );
% 
% This is the registration method based on the translation only, 
% image2 is the template, will not change
% [s_1, s_2]=im_reg_MI(image1, image2 );

% scale 4
a_1 = imresize(image1, 0.25,'bicubic'); % Coarse grain image
a_2 = imresize(image2, 0.25,'bicubic');

L1 = -3:3;
L2 = -3:3;

for i = 1:length(L1)
    for j = 1:length(L2)
        h(i,j) = M_I_2( im_shift(a_1, L1(i), L2(j)), a_2 );
    end
end
[s1,s2] = find(h==max(h(:))); % find the maximum mutual information
image1 = im_shift(image1, 4*L1(s1(1)), 4*L2(s2(1))); % Shift the first image 
a_1 = 0; a_2 = 0; L0 = 0; h = 0;

% scale 2
a_1 = imresize(image1, 0.5,'bicubic'); % Coarse grain image
a_2 = imresize(image2, 0.5,'bicubic');

L3 = -3:3;
L4 = -3:3;

for i = 1:length(L3)
    for j = 1:length(L4)
        h(i,j) = M_I_2( im_shift(a_1, L3(i), L4(j)), a_2 );
    end
end
[s3,s4] = find(h==max(h(:))); % find the maximum mutual information
image1 = im_shift(image1, 2*L3(s3(1)), 2*L4(s4(1))); % Shift the first image 
a_1 = 0; a_2 = 0; L0 = 0; h = 0;



% Do the normal scale image registration
a_1 = 0; a_2 = 0; L0 = 0; h = 0;


a_1 = image1 ; % 
a_2 = image2;

L5 = -3:3; % all the shifting steps
L6 = -3:3;

for i = 1:length(L5)
    for j = 1:length(L6)
        h(i,j) = M_I_2( im_shift(a_1, L5(i), L6(j)), a_2 );
    end
end

[s5,s6] = find(h==max(h(:))); % find the maximum mutual information
% imagesc(h), pause


s_1 = 4*L1(s1(1)) + 2*L3(s3(1)) + L5(s5(1));
s_2 = 4*L2(s2(1)) + 2*L4(s4(1)) + L6(s6(1));






