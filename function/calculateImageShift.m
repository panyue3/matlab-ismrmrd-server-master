function [imshift, refIma_crop] = calculateImageShift(group, metadata, logging, ref)

% Set MOCO parameters
moco = 1; % MOCO method: 1 - Siemens, 2 - Demon
param.mocoReg = 12;
Options.SigmaFluid = 5;
Options.SigmaDiff = 1;
Options.Interpolation = 'Cubic';
Options.Alpha = 4;
Options.Similarity = 'p';
Options.Registration = 'NonRigid';
Options.MaxRef = 5;
Options.Verbose = 0;

% Extract image data
tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
filename = sprintf("%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
nOri = max(cell2mat(cellfun(@(x) x.head.slice, group, 'UniformOutput', false))) + 1;
nRep = max(cell2mat(cellfun(@(x) x.head.repetition, group, 'UniformOutput', false))) + 1;
szPix = single(group{1}.head.field_of_view(1:2)) ./ single(group{1}.head.matrix_size(1:2));
isFlip = false(1,nOri);
cData = cellfun(@(x) x.data, group, 'UniformOutput', false);
try
    data = cat(3, cData{:});
catch
    for iOri = 2:nOri
        if isFlip(1) ~=true 
            if sum(size(cData{1}) ~= size(cData{iOri}))
                isFlip(1) = true;
                for ii = 1:nOri:numel(cData)
                    cData{ii} = transpose(cData{ii});
                end
            end
        else
            if sum(size(cData{1}) ~= size(cData{iOri}))
                isFlip(iOri) = true;
                for ii = iOri:nOri:numel(cData)
                    cData{ii} = transpose(cData{ii});
                end
            end
        end
    end
    data = cat(3, cData{:});
end

% Normalize and convert to short (uint16)
data = data .* (65535./max(data(:)));
data = uint16(round(data));

% Sort images by orientation
imAll = nan([size(data,[1 2]), nRep, size(data,3)/nRep]);
for iOri = 1:nOri
    imAll(:,:,:,iOri) = data(:,:,cell2mat(cellfun(@(x) x.head.slice, group, 'UniformOutput', false))==iOri-1);
end

if nargin > 3   
    if all(isFlip == ref.isFlip)
        try
            imAll = cat(3, ref.refIma, imAll);
            nRep = nRep + 1;
        catch
            logging.warn("Can not concatenate images, no external reference used.")
        end
    else
        logging.warn("Can not concatenate images, no external reference used.")
    end
end

% Run MOCO
rectSer = centerCropWindow2d(size(imAll,[1 2]),round(size(imAll,[1 2])/3));
imDisp = nan(nRep,3,nOri);
% nmse = nan(nRep,nOri);
ssimval = nan(nRep,nOri);
for iOri = 1:nOri
    % +++ Find image orientation +++
    meta = ismrmrd.Meta.deserialize(group{iOri}.attribute_string);
    rotMatrix = [meta.ImageColumnDir; meta.ImageRowDir];
    if isFlip(iOri)
        rotMatrix = flip(rotMatrix);
    end
    % === Find image orientation ===

    % +++ Find end respiratory frame by MOCO first 10 frame +++
    BSer = imAll(:,:,:,iOri);

    if iOri ==1
        if ~contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true) && nRep ~= (max(cell2mat(cellfun(@(x) x.head.repetition, group, 'UniformOutput', false))) + 1)
            idx = 1;
        elseif nRep > 10
            [~, zOri] = max(abs(rotMatrix(:,3)));
            if  zOri == 1
                switch moco
                    case 1
                        [~,Dx] = mocoDisp(BSer(:,:,2:12), 5, param.mocoReg);
                        parfor ii = 1:11
                            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
                        end
                    case 2
                        Dx_crop = zeros([round(size(imAll,[1 2])/3),11]);
                        parfor ii = 1:11
                            [~, ~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                end
            else
                switch moco
                    case 1
                        [Dx,~] = mocoDisp(BSer(:,:,2:12), 5, param.mocoReg);
                        parfor ii = 1:11
                            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
                        end
                    case 2
                        Dx_crop = zeros([round(size(imAll,[1 2])/3),11]);
                        parfor ii = 1:11
                            [~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                end
            end

            valMed= median(squeeze(mean(Dx_crop, [1,2])));
            idx = find(squeeze(mean(Dx_crop, [1,2])) == valMed,1) + 1;
        else
            idx = round(nRep/2);
        end

        if contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true)
            refIma = imAll(:,:,idx,:);
            if ispc
                save(fullfile(pwd,'output',filename),'refIma','isFlip');
            elseif isunix
                save(fullfile('/tmp/share/prompt',filename),'refIma','isFlip');
            end
        end
    end
    % === Find end respiratory frame by MOCO first 10 frame ===

    % +++ MOCO all images use end respiratory frame as reference +++
    Iref = imcrop(BSer(:,:,idx),rectSer);

    switch moco
        case 1
            [Dx_Ser,Dy_Ser] = mocoDisp(BSer, idx, param.mocoReg);
            Am_Ser = mocoApply(double(BSer), Dx_Ser, Dy_Ser);
            Icomb = cat(2, BSer, Am_Ser);

            parfor iRep = 1:nRep
                Dx_Ser_crop(:,:,iRep) = imcrop(Dx_Ser(:,:,iRep),rectSer);
                Dy_Ser_crop(:,:,iRep) = imcrop(Dy_Ser(:,:,iRep),rectSer);
                Ireg = imcrop(Am_Ser(:,:,iRep),rectSer);

                % Calculate NMSE and SSIM
%                 nmse(iRep,iOri) = sum((Iref(:) - Ireg(:)).^2)/sum(Iref(:).^2);
                ssimval(iRep,iOri) =  ssim(Iref, Ireg)
            end
        case 2
            Dx_Ser_crop = nan([round(size(BSer,[1 2])/3),nRep]);
            Dy_Ser_crop = nan([round(size(BSer,[1 2])/3),nRep]);
            Icomb = nan(size(BSer,1),size(BSer,2)*2,nRep);
            parfor iRep = 1:nRep
                logging.info("Estimating motion for frame %i/%i ", iRep, nRep)
                [Ireg, Dx_Ser, Dy_Ser] = register_images(BSer(:,:,iRep), BSer(:,:,idx), Options);
                Dx_Ser_crop(:,:,iRep) = imcrop(Dx_Ser,rectSer);
                Dy_Ser_crop(:,:,iRep) = imcrop(Dy_Ser,rectSer);
                Icomb(:,:,iRep) = cat(2, BSer(:,:,iRep), Ireg);
                Ireg = imcrop(Ireg,rectSer);

                % Calculate NMSE
%                 nmse(iRep,iOri) = sum((Iref(:) - Ireg(:)).^2)/sum(Iref(:).^2);
                ssimval(iRep,iOri) =  ssim(Iref, Ireg)
            end
    end
    % === MOCO all images use end respiratory frame as reference ===

    % +++ Save MOCOed images +++
    if ispc
        clear im
        figname = sprintf("%s.%s_%s_IMG_MOCO_Ori%i.gif",tmp{11}, tmp{end}, metadata.measurementInformation.protocolName, iOri);
        for iRep = 1:nRep
            im = uint8(Icomb(:,:,iRep)/max(Iref(:))*255);

            if iRep == 1
                imwrite(im,fullfile(pwd,'output',figname), 'gif', 'Loopcount', inf);
            else
                imwrite(im,fullfile(pwd,'output',figname),'gif', 'DelayTime', 0.25, 'WriteMode','append');
            end
        end
    end
    % === Save MOCOed images ===

    % +++ Save outlier +++
    thrd = min([mean(ssimval(:,iOri),'omitnan') - 3*std(ssimval(:,iOri),[],'omitnan') 2.5*quantile(ssimval(:,iOri), 0.25)-1.5*quantile(ssimval(:,iOri), 0.75)]);
    isoutlier(ssimval(:,iOri) < thrd) = true;
    % === Save outlier ===

    % +++ Plot SSIM  +++
    if ispc
        fig = figure(1);
        subplot(double(nOri),1,double(iOri))
        plot(ssimval(:,iOri),'*')
        if sum(ssimval(:,iOri) < thrd)
            hold on
            line([0 nRep],[thrd thrd],'Color','k','LineStyle','--')
            hold off
        end
        title(sprintf('Ref frame %i, Mean SSIM: %0.2f',idx,mean(ssimval(:,iOri),'omitnan')))
    end
    % === Plot SSIM ===

    imDisp(:,:,iOri) = [squeeze(mean(mean(Dy_Ser_crop,1),2))*szPix(1), squeeze(mean(mean(Dx_Ser_crop,1),2))*szPix(2)] * single(rotMatrix);
    refIma_crop(:,:,iOri) = Iref;
end    % end of count Ori

[~, idx] = sort(mean(ssimval,'omitnan'),'descend');
imshift = squeeze(imDisp(:,:,idx(1)));
imshift(:,~imshift(end,:)) = squeeze(imDisp(:,~imshift(end,:),idx(2)));

if nRep ~= (max(cell2mat(cellfun(@(x) x.head.repetition, group, 'UniformOutput', false))) + 1)
    imshift(1,:) = [];
    isoutlier(1) = [];
end

% Save SSIM plot
if ispc
    figname = sprintf("%s.%s_%s_SSIM.png", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
    saveas(fig, fullfile(pwd,'output',figname))
    close(fig)
end

end