function [moco, dx, dy, dxInv, dyInv] = PerformMoCo(ref, align, iters, sigma)
% [moco, dx, dy, dxInv, dyInv] = PerformMoCo(ref, align, iters, sigma)
% ref: reference image for moco
% align: aligned image for moco
% iters: number of iterations, e.g [32 32 32]
% sigma: regularization strength, e.g. 12

% inputs:
ref=double(ref);
align=double(align);

voxelsize = [1 1 1 1];
header = CreateFtkHeaderInfo(ref, voxelsize);

[moco, dx, dy, dxInv, dyInv] = Matlab_PerformPairWiseMotionCorrection(ref, align, header, iters, sigma);

end

function header = CreateFtkHeaderInfo(data, voxelsize)

    [ysize, xsize, zsize, tsize, nsize, msize] = size(data);

    if ( ~isempty(voxelsize) )
        header = struct('sizeX', xsize, 'sizeY', ysize, 'sizeZ', zsize, 'sizeT', tsize, 'sizeN', nsize, 'sizeM', msize, ... 
            'spacingX', voxelsize(1), 'spacingY', voxelsize(2), 'spacingZ', voxelsize(3), ... 
            'spacingT', 1.0, 'spacingN', 1.0, 'spacingM', 1.0, 'positionPatient', [0 0 0], 'orientationPatient', eye(3,3));
    else
        header = struct('sizeX', xsize, 'sizeY', ysize, 'sizeZ', zsize, 'sizeT', tsize, 'sizeN', nsize, 'sizeM', msize, ... 
            'spacingX', 1.0, 'spacingY', 1.0, 'spacingZ', 1.0, ... 
            'spacingT', 1.0, 'spacingN', 1.0, 'spacingM', 1.0, 'positionPatient', [0 0 0], 'orientationPatient', eye(3,3));
    end
end
