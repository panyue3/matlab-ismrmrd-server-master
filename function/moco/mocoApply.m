function [Am] = mocoApply(A, Dx, Dy)

n  = size(Dx);
A = reshape(A, size(Dx));
Am = zeros(n);

for i = 1:n(3)
    a = A(:,:,i);
    [y,x] = meshgrid(-n(2)/2:n(2)/2-1, -n(1)/2:n(1)/2-1);
    xq = x + Dx(:,:,i);
    yq = y + Dy(:,:,i);
    Am(:,:,i) = interp2(y,x,a,yq,xq,'spline');
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




