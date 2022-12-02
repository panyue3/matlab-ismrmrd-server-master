function [ImData, refIma] = CalcShiftFromIMG(refIma, genFig)
%CalcShiftFromIMG   Prompt for the user to select a directory that contains
%   a series of DICOM images, and returns the slice shifting parameters 
%   calculated from these images.
%
%   Inputs:
%       refIma: If reference frame is provided, shifting parameter will be
%           calculated based on reference frame, if no reference frame
%           provided, shifting parameter will be calculated based on first
%           frame in the series.
%
%       genFig: A scalar value to determine if a gif file should be saved
%           in the image directory displaying frames before and after MOCO.
%           If no value is proviede, genFig is set to 0.
%
%   Outputs:
%       ImData: An nRep by 2 matrix containing slice shifting parameters.
%
%       refIma: Reference images used to calculate shifting parameter.
%
%   Examples:
%       ImData = CalcShiftFromIMG;
%       ImData = CalcShiftFromIMG(refIma);
%       [ImData, refIma] = CalcShiftFromIMG(genFig);
%
%   Created by Yue Pan, May 2021.

switch nargin
    case 0
        extRef = 0;
        genFig = 0;
    case 1
        if length(refIma(:)) >  1
            extRef = 1;
            genFig = 0;
        else
            extRef = 0;
            genFig = refIma;
            clear refIma
        end
    case 2
        extRef = 1;
    otherwise
        error(message('Too many input arguments'));
end

%% Set up script path and load data
% Add motion model definition script to path
addpath('moco');

% Load image data
prompt = 'Load DICOM folder';
TrainPath = uigetdir('C:\MIDEA\NXVA31A_176478\src\MrImaging\seq\a_BEAT_PT\meas',prompt);
if(TrainPath == 0)
    return;
end
SeriesTable = dicomCollection(TrainPath);

nRep = height(SeriesTable.Filenames{1,1}); % number of frames collected

info(1) = dicominfo(SeriesTable.Filenames{1,1}(1));
info(2) = dicominfo(SeriesTable.Filenames{1,1}(round(nRep/2)+1));
ori2 = ~all(info(1).ImageOrientationPatient == info(2).ImageOrientationPatient);
if ori2
    nRep = round(nRep/2);
else
    info(2) = [];
end

for ii = 1:nRep
    im = dicomread(SeriesTable.Filenames{1,1}(ii));
    ImAll(:,:,ii,1) = im;%(size(im,1)/2-50:size(im,1)/2+49,size(im,2)/2-50:size(im,2)/2+49);
    if ori2
        im = dicomread(SeriesTable.Filenames{1,1}(ii+nRep));
        ImAll(:,:,ii,2) = im;%(size(im,1)/2-50:size(im,1)/2+49,size(im,2)/2-50:size(im,2)/2+49);
    end
end

%% Map image displacement to XYZ direction
% +X: Left, +Y: Posterior, +Z: Superior
[ImOri, ~] = find(reshape(info(1).ImageOrientationPatient,3,[]));
ImDir = sum(reshape(info(1).ImageOrientationPatient,3,[]))';
if ori2
    [ImOri(:,2), ~] = find(reshape(info(2).ImageOrientationPatient,3,[]));
    ImDir(:,2) = sum(reshape(info(2).ImageOrientationPatient,3,[]))';
end

%% Add reference frame to series
if extRef
    try
        ImAll = cat(3, refIma, ImAll);
    catch
        warning('Can not concatenate images, no external reference used.');
    end
end

%% Run motion correction to calculate displacment
param.mocoReg = 12;

for kk = 1:size(ImAll,4)
    ImSer = ImAll(:,:,:,kk);
    BSer = 100*ImSer/max(ImSer(:));

    if extRef
        idx = 1;
        figure; colormap gray
        [ImcropSer, rectSer] = imcrop(imagesc(abs(squeeze(ImSer(:,:,1))),[0, 3*max(abs(BSer(:)))]));
        close
    else
        figure; colormap gray
        [ImcropSer, rectSer] = imcrop(imagesc(abs(squeeze(mean(ImSer(:,:,1:10),3))),[0, 3*max(abs(BSer(:)))]));
        close

        [Dx,~] = mocoDisp(BSer(:,:,1:10), 1, param.mocoReg);
        Dx_crop = zeros([size(ImcropSer),size(Dx,3)]);
        for ii = 1:10
            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
        end
        [~, idx] = max(squeeze(mean(Dx_crop, [1,2]))*ImDir(2,kk));
        refIma(:,:,1,kk) = double(ImSer(:,:,idx));

        figure; colormap gray
        [ImcropSer, rectSer] = imcrop(imagesc(abs(squeeze(ImSer(:,:,idx))),[0, 3*max(abs(BSer(:)))]));
        close
    end

    [Dx_Ser,Dy_Ser] = mocoDisp(BSer, idx, param.mocoReg);

    if genFig
        Am_Ser  = mocoApply(double(BSer), Dx_Ser, Dy_Ser);
        x_xreg_Ser = cat(2, BSer, Am_Ser);

        clear im
        filename = sprintf('IMG_MOCO_%i.gif',kk);
        filename = fullfile(TrainPath,filename);
        for n = 1:size(x_xreg_Ser,3)
            im = uint8(10*x_xreg_Ser(:,:,n));
            if n == 1
                imwrite(im,filename, 'gif', 'Loopcount', inf);
            else
                imwrite(im,filename,'gif', 'DelayTime', 0.25, 'WriteMode','append');
            end
        end
    end

    Dx_Ser_crop = zeros([size(ImcropSer),size(Dx_Ser,3)]);
    Dy_Ser_crop = zeros([size(ImcropSer),size(Dy_Ser,3)]);
    for jj = 1:size(BSer,3)
        Dx_Ser_crop(:,:,jj) = imcrop(Dx_Ser(:,:,jj),rectSer);
        Dy_Ser_crop(:,:,jj) = imcrop(Dy_Ser(:,:,jj),rectSer);
    end

    ImDisp = [];
    try
        ImDisp(:,1) = squeeze(mean(mean(Dy_Ser_crop,1),2))*info(1).PixelSpacing(1)*info(1).PixelSpacing(2);
        ImDisp(:,2) = squeeze(mean(mean(Dx_Ser_crop,1),2))*info(1).PixelSpacing(1)*info(1).PixelSpacing(2);
    catch
        warning('info.PixelSpactin not existed');
        ps = str2double(cell2mat(inputdlg({'Enter pixel spacing: '}))); % previous defult protocol 2.08
        ImDisp(:,1) = squeeze(mean(mean(Dy_Ser_crop,1),2))*ps^2;
        ImDisp(:,2) = squeeze(mean(mean(Dx_Ser_crop,1),2))*ps^2;
    end

    if extRef
        ImDisp(1,:) = [];
    end
    
    ImData(:,ImOri(:,kk)) = ImDisp .* ImDir(:,kk)';
end

% plot(ImData); legend('dX','dY','dZ')

if extRef
    save([TrainPath '.mat'], 'ImData')
else
    save([TrainPath '.mat'], 'ImData', 'refIma')
end

end