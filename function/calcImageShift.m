function imshift = calcImageShift(group, metadata, logging)

% Set MOCO parameters
moco = 2; % MOCO method: 1 - Siemens, 2 - Demon
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
nOri = max(cell2mat(cellfun(@(x) x.head.slice, group, 'UniformOutput', false))) + 1;
nRep = max(cell2mat(cellfun(@(x) x.head.repetition, group, 'UniformOutput', false))) + 1;
szPix = single(group{1}.head.field_of_view(1:2)) ./ single(group{1}.head.matrix_size(1:2));
isFlip = false(1,nOri);
cData = cellfun(@(x) x.data, group, 'UniformOutput', false);
try
    data = cat(3, cData{:});
catch
    for iOri = 2:nOri
        if sum(size(cData{1}) ~= size(cData{iOri}))
            isFlip(iOri) = true;
            for ii = iOri:nOri:numel(cData)
                cData{ii} = transpose(cData{ii});
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
imAll = permute(imAll, [2, 1, 3, 4]);

% Run MOCO
rectSer = centerCropWindow2d(size(imAll,[1 2]),round(size(imAll,[1 2])/3));
imshift = nan(nRep,3);
nmse = nan(nOri, nRep);
for iOri = 1:nOri
    % +++ Find image orientation +++
    [readphaseDir, readphaseOri] = max(abs([group{iOri}.head.read_dir; group{iOri}.head.phase_dir]),[],2);
    if sum(readphaseDir) ~= 2
        logging.warn("Images acquired are not in true sagital, coronal, or axial plane.")
    end
    switch sum(readphaseOri)
        case 3
            imOri = [1 2];
            imDir = [1 1];
        case 4
            imOri = [1 3];
            imDir = [1 -1];
        case 5
            imOri = [2 3];
            imDir = [1 -1];
    end
    % === Find image orientation ===

    % +++ Find end respiratory frame by MOCO first 10 frame +++
    BSer = imAll(:,:,:,iOri);

    if iOri ==1
        if nRep > 10
            if  imOri(1) == 3
                switch moco
                    case 1
                        [~,Dx] = mocoDisp(BSer(:,:,2:11), 5, param.mocoReg);
                        parfor ii = 1:10
                            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
                        end
                    case 2
                        Dx_crop = zeros([round(size(imAll,[1 2])/3),10]);
                        parfor ii = 1:10
                            [~, ~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                end

                [~, idxMax] = max(squeeze(mean(Dx_crop, [1,2]))*imDir(1));
                [~, idxMin] = min(squeeze(mean(Dx_crop, [1,2]))*imDir(1));
                idx = round(mean([idxMax, idxMin])) + double(idxMax>idxMin);
            else
                switch moco
                    case 1
                        [Dx,~] = mocoDisp(BSer(:,:,2:11), 5, param.mocoReg);
                        parfor ii = 1:10
                            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
                        end
                    case 2
                        Dx_crop = zeros([round(size(BSer,[1 2])/3),10]);
                        parfor ii = 1:10
                            [~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                end

                [~, idxMax] = max(squeeze(mean(Dx_crop, [1,2]))*imDir(2));
                [~, idxMin] = min(squeeze(mean(Dx_crop, [1,2]))*imDir(2));
                idx = round(mean([idxMax, idxMin])) + double(idxMax>idxMin);
            end
        else
            idx = round(nRep/2);
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

                % Calculate NMSE
                Ireg = imcrop(Am_Ser(:,:,iRep),rectSer);
                nmse(iOri,iRep) = sum((Iref(:) - Ireg(:)).^2)/sum(Iref(:).^2);
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
                nmse(iOri,iRep) = sum((Iref(:) - Ireg(:)).^2)/sum(Iref(:).^2);
            end
    end
    % === MOCO all images use end respiratory frame as reference ===

    % +++ Save MOCOed images +++
    if ispc
        clear im
        tmp = split(metadata.measurementInformation.frameOfReferenceUID,'.');
        filename = sprintf("IMG_MOCO_Ori%i_%s_%s.gif",iOri,metadata.measurementInformation.protocolName, tmp{11});
        for iRep = 1:nRep
            im = uint8(Icomb(:,:,iRep)/max(Iref(:))*255);

            if iRep == 1
                imwrite(im,fullfile(pwd,'output',filename), 'gif', 'Loopcount', inf);
            else
                imwrite(im,fullfile(pwd,'output',filename),'gif', 'DelayTime', 0.25, 'WriteMode','append');
            end
        end
    end
    % === Save MOCOed images ===

    % +++ Plot NMSE  +++
    if ispc
        setPlotDefault
        nmse(iOri,1) = nan;
        fig = figure(1);
        subplot(double(nOri),1,double(iOri))
        plot(nmse(iOri,:))
        title(sprintf('Ref frame %i, Mean NMSE x 1000: %0.2f',idx,mean(nmse(iOri,:),'omitnan')*1000))
    end
    % === Plot NMSE ===

    % +++ Save imshift +++
    imDisp = [];
    imDisp(:,1) = squeeze(mean(mean(Dy_Ser_crop,1),2))*szPix(1)*szPix(2);
    imDisp(:,2) = squeeze(mean(mean(Dx_Ser_crop,1),2))*szPix(1)*szPix(2);
    [~, iMin] = min(mean(nmse*1000,2,'omitnan'),[],'omitnan');
    if iOri == iMin
        imshift(:,imOri) = imDisp .* imDir;
    else
        for ii = 1:width(imDisp)
            if sum(isnan(imshift(:,imOri(ii))))
                imshift(:,imOri(ii)) = imDisp(:,ii) .* imDir(ii);
            end
        end
    end
    % === Save imshift ===

end    % end of count Ori

% Save NMSE plot
if ispc
    filename = sprintf("%s_%s_NMSE.png",metadata.measurementInformation.protocolName, tmp{11});
    saveas(fig, fullfile(pwd,'output',filename))
    close(fig)
end

end