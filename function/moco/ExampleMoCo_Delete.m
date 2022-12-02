close all;
clear;

% load exampleData
% n = size(ref);
% ref = phantom('modified shepp-logan', n);
% align = imrotate(ref,1);
% align = circshift(ref, [0,-0]);
% ref = imrotate(ref, 5); ref = ref(5:end-5,5:end-5);
data = importdata('H:\CoL1\FID207952_xHat2_2_1_sl1_R1.mat');
refID = ceil(size(data,3)/3);
R = data(:,:,refID);
n = size(R);
dF = 5; % display frequency

Dx = zeros(size(data));
Dy = Dx;
DxInv = Dx;
DyInv = Dy;
for i = 1:size(data,3)
    A = data(:,:,i);
    [Am, dy, dx, dyInv, dxInv] = PerformMoCo(R, A,  1*[32 32 32], 5); % Rizwan: I have reversed the order of dx, dy; last number higher = less deformation
    [Amm, ~, ~, ~, ~]          = PerformMoCo(A, Am, 1*[32 32 32], 5); % Rizwan: I have reversed the order of dx, dy
    
    Dx(:,:,i) = dx;
    Dy(:,:,i) = dy;
    DxInv(:,:,i) = dxInv;
    DyInv(:,:,i) = dyInv;
    
    
    % Let's do the interpolation outside the Siemens' code
    [y,x] = meshgrid(-n(2)/2:n(2)/2-1, -n(1)/2:n(1)/2-1);
    xq = x + Dx(:,:,i);
    yq = y + Dy(:,:,i);
    ARm = interp2(y,x,A,yq,xq,'spline');

    xq = x + DxInv(:,:,i);
    yq = y + DyInv(:,:,i);
    ARmm = interp2(y,x,ARm,yq,xq,'spline');
    ARmm(isnan(ARmm)) = 0;

    mx = max([abs(R(:)); abs(A(:))]);
    if rem(i,dF) == 0
        figure;
        subplot(2,3,1); imagesc(abs(A), [0, mx]); axis('image'); colormap(gray); title('to align');
        subplot(2,3,2); imagesc(abs(Amm),[0,mx]);axis('image'); colormap(gray); title(['re-aligend (Sie), SNR: ' num2str(-20*log10(norm(A-Amm)/norm(A(:))))]);
        subplot(2,3,3); imagesc(abs(ARmm),[0,mx]);axis('image'); colormap(gray); title(['re-aligend (Sie), SNR: ' num2str(-20*log10(norm(A-ARmm)/norm(A(:))))]);
        subplot(2,3,4); imagesc(abs(R),[0,mx]);axis('image'); colormap(gray); title('ref');
        subplot(2,3,5); imagesc(abs(Am),[0,mx]);axis('image'); colormap(gray); title('aligned (Sie)');
        subplot(2,3,6); imagesc(abs(ARm),[0,mx]);axis('image'); colormap(gray); title('aligned (RA)');
    end
end



%%
% clc
% [Y,X] = meshgrid(-16:15);
% V = peaks(32);
% figure
% surf(Y,X,V)
% title('Original Sampling');
% [Yq,Xq] = meshgrid(-16:0.5:15);
% Vq = interp2(Y,X,V,Yq,Xq,'cubic');
% figure
% surf(Yq,Xq,Vq);
% title('Cubic Interpolation Over Finer Grid');




