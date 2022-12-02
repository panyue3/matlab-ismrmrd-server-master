function [Dx, Dy, DxInv, DyInv] = mocoBackward(A, R, lmb)

n  = size(A);
Dx = zeros(n);
Dy = Dx;
DxInv = Dx;
DyInv = Dy;
dF = ceil(n(3)/2)+1; % display frequency

for i = 1:n(3)
    a = A(:,:,i);
    [Am, dy, dx, dyInv, dxInv] = PerformMoCo(R, a,  1*[32 32 32], lmb); % Rizwan: I have reversed the order of dx, dy; last number higher = less deformation
    [Amm, ~, ~, ~, ~]          = PerformMoCo(a, Am, 1*[32 32 32], lmb); % Rizwan: I have reversed the order of dx, dy
    
    Dx(:,:,i) = dx;
    Dy(:,:,i) = dy;
    DxInv(:,:,i) = dxInv;
    DyInv(:,:,i) = dyInv;
    
    if rem(i,dF) == 0
        % Let's do the interpolation outside the Siemens' code
        [y,x] = meshgrid(-n(2)/2:n(2)/2-1, -n(1)/2:n(1)/2-1);
        xq = x + Dx(:,:,i);
        yq = y + Dy(:,:,i);
        ARm = interp2(y,x,a,yq,xq,'spline');

        xq = x + DxInv(:,:,i);
        yq = y + DyInv(:,:,i);
        ARmm = interp2(y,x,ARm,yq,xq,'spline');
        ARmm(isnan(ARmm)) = 0;

        mx = max([abs(R(:)); abs(a(:))]);
        figure;
        subplot(2,3,1); imagesc(abs(a), [0, mx]); axis('image'); colormap(gray); title('to align');
        subplot(2,3,2); imagesc(abs(Amm),[0,mx]);axis('image'); colormap(gray); title(['re-aligend (Sie), SNR: ' num2str(-20*log10(norm(a-Amm)/norm(a(:))))]);
        subplot(2,3,3); imagesc(abs(ARmm),[0,mx]);axis('image'); colormap(gray); title(['re-aligend (Sie), SNR: ' num2str(-20*log10(norm(a-ARmm)/norm(a(:))))]);
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




