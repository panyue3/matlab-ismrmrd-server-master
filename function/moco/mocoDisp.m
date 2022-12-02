function [Dx, Dy, DxInv, DyInv] = mocoDisp(A, ref, lmb)

% n  = size(A);
% Dx = zeros(n);
% Dy = Dx;
% DxInv = Dx;
% DyInv = Dy;
% R = A(:,:,ref);
% 
% for i = 1:n(3)
%     a = A(:,:,i);
%     [Am, dy, dx, dyInv, dxInv] = PerformMoCo(R, a,  1*[32 32 32], lmb); % Rizwan: I have reversed the order of dx, dy; last number higher = less deformation
%     
%     Dx(:,:,i) = dx;
%     Dy(:,:,i) = dy;
%     DxInv(:,:,i) = dxInv;
%     DyInv(:,:,i) = dyInv;
% end


n  = size(A);
Dx = zeros(n);
Dy = Dx;
DxInv = Dx;
DyInv = Dy;
R= A(:,:,ref);
for i = ref+1:size(A,3)
    a = A(:,:,i);
    [Am, dy, dx, dyInv, dxInv] = PerformMoCo(R, a,  1.5*[32 32 32], lmb); % Rizwan: I have reversed the order of dx, dy; last number higher = less deformation
%     R = Am;
    Dx(:,:,i) = dx;
    Dy(:,:,i) = dy;
    DxInv(:,:,i) = dxInv;
    DyInv(:,:,i) = dyInv;
end

R= A(:,:,ref);
for i = ref-1:-1:1
    a = A(:,:,i);
    [Am, dy, dx, dyInv, dxInv] = PerformMoCo(R, a,  1.5*[32 32 32], lmb); % Rizwan: I have reversed the order of dx, dy; last number higher = less deformation
%     R = Am;
    Dx(:,:,i) = dx;
    Dy(:,:,i) = dy;
    DxInv(:,:,i) = dxInv;
    DyInv(:,:,i) = dyInv;
end