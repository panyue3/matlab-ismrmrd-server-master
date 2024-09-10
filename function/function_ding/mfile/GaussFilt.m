function [ W ] = GaussFilt( NX,NY,Std)
%
%
%
% NX = 128; NY = NX; Std = 8;

KxCenter = floor(NX/2) + 1;
KyCenter = floor(NY/2) + 1;

W = zeros(NX,NY);

for lx = 1:NX
    for ly = 1:NY
        dx = abs(lx-KxCenter);
        dy = abs(ly-KyCenter);
        W(lx,ly) = exp(-(dx*dx + dy*dy)/(Std*Std));
    end
end

% imashow(W); imashow(abs(fft2c(W)));



