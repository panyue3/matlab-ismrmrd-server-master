
function [combinedIm, sensitivityMap] = adaptiveCoilCombination2D(complexImage, neighborSize, noiseCorrelationMatrix)
%
% [combinedIm, sensitivityMap] = adaptiveCoilCombination2D(complexImage, neighborSize, noiseCorrelationMatrix)
%
% ------------------------ input ------------------------
% complexImage : complex images, [Nfe Npe header.num_coils)]
% neighborSize : neighbor size for FE and PE directions [neighborFE neighborPE]; thus, a total of neighborFE*neighborPE points are used to estimate
% signal correlation matrix for each pixel
% 
% ------------------------ output ------------------------
% combinedIm : combined complex image
% sensitivityMap : estimated sensitivity map for each point
% 
% Hui Xue
% Jan 24, 2011
%
% References:   Adaptive Reconstruction of Phased Array MR Imagery MRM 43:682-690 2000
% ========================================================
s = size(complexImage);
numOfCoils = s(3);
Nfe = s(1);
Npe = s(2);

combinedIm = zeros([Nfe Npe]);
sensitivityMap = zeros(s);

halfNeighborFE = floor(neighborSize(1)/2);
halfNeighborPE = floor(neighborSize(2)/2);

% compute the inverse of noise correlation matrix
invNoiseCov = inv_reg(noiseCorrelationMatrix, 1e-5);

% normalized by SoS images
Img = zeros(s(1), s(2));
for z_index=1:s(3)
    Img = Img + conj(complexImage(:,:,z_index)).*complexImage(:,:,z_index);
end
Img = sqrt(Img);

complexImage2 = complexImage;
for z_index=1:s(3)
    complexImage(:,:,z_index) = complexImage(:,:,z_index) ./ Img;
end

for pe = 1:Npe
    % disp(['phase encoding line : ' num2str(pe)]);
    for fe = 1:Nfe
        
        X = fe-halfNeighborFE:fe+halfNeighborFE;
        Y = pe-halfNeighborPE:pe+halfNeighborPE;
        
        % apply the mirror boundary condition
        ind = find(X<1);
        X(ind) = 2 - X(ind);
        ind = find(X>Nfe);
        X(ind) = 2*Nfe - X(ind);

        ind = find(Y<1);
        Y(ind) = 2 - Y(ind);
        ind = find(Y>Npe);
        Y(ind) = 2*Npe - Y(ind);
                
        % get the signal for each coil
        signal = complexImage(X, Y, :);       
        signal = reshape(signal, [numel(X)*numel(Y) numOfCoils]);
        signal = signal.';
        Rs = signal*signal';        
        
        R = invNoiseCov*Rs;        
        [V,D]=eig(R);        
        combinedIm(fe, pe) = reshape(complexImage2(fe, pe, :), [1 numOfCoils]) * conj(V(:,end));
        sensitivityMap(fe, pe, :) = reshape(V(:,end), [1 1 numOfCoils]);                
    end
end
