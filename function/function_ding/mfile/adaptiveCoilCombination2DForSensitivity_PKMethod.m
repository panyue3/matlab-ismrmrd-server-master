
function [combinedIm, sensitivityMap] = adaptiveCoilCombination2DForSensitivity_PKMethod(complexImage, spatialSmoothingKernel)
%
% [combinedIm, sensitivityMap] = adaptiveCoilCombination2DForSensitivity(complexImage, neighborSize, noiseCorrelationMatrix)
% This function implements the adaptive coil combination especially for sensitivity estimation
% a) root-sum-of-squares normalization
% b) compute signal correlation matrix for every pixel; not using neighborhood, but do S*S' outer product
% c) apply spatial smoothing on each element of correlation matrix; In this step, corresponding element of signal cov matrix is put together as a Nfe*Npe image.
% The filter is applied on the cov element image. Following PK's comments, the simple averaging filter is applied.
% d) for every pixel, compute the most dominant eigenvector corresponding to largest eigen value; this eigenvector is coil sensitivity for this pixel
% ------------------------ input ------------------------
% complexImage : complex images, [Nfe Npe header.num_coils)]
% signal correlation matrix for each pixel
% spatialSmoothingKernel : spatial smoothing kernel size for simple averaging filter
%
% ------------------------ output ------------------------
% combinedIm : combined complex image
% sensitivityMap : estimated sensitivity map for each point
% 
% Hui Xue
% Jan 24, 2011
%
% References:   Adaptive Reconstruction of Phased Array MR Imagery MRM 43:682-690 2000
% PK's comments:
% We create a cross-correlation matrix as the outer product of the complex data at each pixel, i.e. the column 
% vector S is Nc x 1 where Nc is the number of channels, and the correlation matrix R = S x SH where SH is the 
% Hermitian or conjugate transponse. We then spatially smooth (filter) the correlation matrix R(x,y) for each 
% of the Nc x Nc components (note that it is conj symm). Finally, we compute the complex coil maps (sensitivity 
% estimates) as the dominant eigenvector of this nearly rank 1 correlation matrix. Generally, we also remove the 
% phase of coil from all coils. The spatial smoothing is generally a relatively small kernel. We do not use a 
% polynomial fitting scheme which never really worked that well. We simply use a sliding window of either 
% 5x5 or 7x7 all ones to simplify computation. In fact for the latest version of IcePAT we compute the spatially 
% averaged correlation on a subsampled matrix accumulated in place, and then interpolate the coil maps back to 
% the original size. In other words, we accumulate the full resolution correlation matrix in an integrate and 
% dump rather than sliding window fashion. This was a significant saving in computation. Both schemes are 
% implemented in IcePAT.
% 
% Another nuance, it whether to normalize before or after. We are taking the raw complex images which in the 
% case of TPAT are the averaged data and then normalize by the root sum of squares to create what we refer 
% to as sensitivities. The modulus (magnitude) of the object is thus removed but the raw sensitivities still 
% contain object phase. The object phase is removed from the correlation matrix which does a conjugate multiplication, 
% and this is why this is done. Then the spatial smoothing may be applied to the corr matrix without any object 
% magn or phase and only has to contend with the more slowly varying coil magn and phase. Of course, the 
% object boundaries such as chest wall are still there and this limits the degree of smoothing that can be done. 
% One could detect these edges and adaptively reduce the smoothing at the edges. In fact this is what 
% Pruessmann did with his polynomial smoothing (unpublished from private conversation) 
% where he uses a zero order everywhere but edges and then uses 1st order. The problem is having reliable 
% edges which caused them problems. An alternative, is to skip the rss magnitude normalization and just 
% do it at the end. I have tried both schemes and never saw a compelling reason to normalized at the end, 
% and it is more theoretically satisfying to normalize first.
% ========================================================
%tic,
s = size(complexImage);
numOfCoils = s(3);
Nfe = s(1);
Npe = s(2);

combinedIm = zeros([Nfe Npe]);
sensitivityMap = zeros(s);

% ------------------------------------------------------------
% a) normalized by SoS images
% ------------------------------------------------------------
Img = zeros(s(1), s(2));
for z_index=1:s(3)
    Img = Img + conj(complexImage(:,:,z_index)).*complexImage(:,:,z_index);
end
Img = sqrt(Img);

complexImage2 = complexImage;
for z_index=1:s(3)
    complexImage(:,:,z_index) = complexImage(:,:,z_index) ./ Img;
end
%{'a', toc, tic}
% ------------------------------------------------------------
% b) compute signal covariance matrix for every pixel
% ------------------------------------------------------------
covArray = zeros(Nfe, Npe, numOfCoils, numOfCoils, 'single');
for pe = 1:Npe
    for fe = 1:Nfe                       
        signal = complexImage(fe, pe, :);
        signal = reshape(signal, [numOfCoils 1]);                
        Rs = signal*signal';                       
        covArray(fe, pe, :, :) = Rs;
    end
end
%{'b', toc, tic}
% ------------------------------------------------------------
% c) apply spatial smoothing on each covariance element array
% ------------------------------------------------------------
kernel = ones(spatialSmoothingKernel, spatialSmoothingKernel)/(spatialSmoothingKernel*spatialSmoothingKernel);
for rowCov = 1:numOfCoils
    for colCov=1:numOfCoils
        smoothedCov = conv2(covArray(:,:,rowCov, colCov), kernel, 'same');
        covArray(:,:,rowCov, colCov) = smoothedCov;
    end
end
%{'c', toc, tic}
% ------------------------------------------------------------
% d) calculate dominant eigenvector and perform the adaptive image combination
% ------------------------------------------------------------
% for pe = 1:Npe
%     for fe = 1:Nfe               
%         R = reshape(covArray(fe, pe, :, :), [numOfCoils numOfCoils]);        
%         [V,D]=eig(R);        
%         combinedIm(fe, pe) = reshape(complexImage2(fe, pe, :), [1 numOfCoils]) * conj(V(:,end));
%         sensitivityMap(fe, pe, :) = reshape(V(:,end), [1 1 numOfCoils]);                
%     end
% end
tic
for pe = 1:Npe
    for fe = 1:Nfe               
        R = reshape(covArray(fe, pe, :, :), [numOfCoils numOfCoils]);        
        temp = R*(squeeze(complexImage(fe, pe, :)));  V = temp/sqrt(sum(abs(temp).^2));      
        combinedIm(fe, pe) = reshape(complexImage2(fe, pe, :), [1 numOfCoils]) * conj(V);
        sensitivityMap(fe, pe, :) = reshape(V, [1 1 numOfCoils]);                
    end
end
%{'d', toc }
% 
% {'d0', toc}, tic 
% for pe = 1:Npe
%     for fe = 1:Nfe               
%         R = reshape(covArray(fe, pe, :, :), [numOfCoils numOfCoils]);                    
%     end
% end
% {'d1', toc}, tic
% for pe = 1:Npe
%     for fe = 1:Nfe                  
%         temp = R^2*(squeeze(complexImage(fe, pe, :)));  V = temp/sqrt(sum(abs(temp).^2));                  
%     end
% end
% {'d2', toc}, tic
% for pe = 1:Npe
%     for fe = 1:Nfe      
%         combinedIm(fe, pe) = reshape(complexImage2(fe, pe, :), [1 numOfCoils]) * conj(V);                
%     end
% end
% {'d3', toc}, tic
% for pe = 1:Npe
%     for fe = 1:Nfe  
%         sensitivityMap(fe, pe, :) = reshape(V, [1 1 numOfCoils]);                
%     end
% end
% {'d4', toc}, 



