function imdata = calculateImageShift(group, metadata, logging, ref)

% Set MOCO parameters
moco = 1; % MOCO method: 1 - Siemens, 2 - Demon, 3 - Normalized Cross Correlation
param.mocoReg = 12;
cropfactor = 4;
Options.SigmaFluid = 5;
Options.SigmaDiff = 1;
Options.Interpolation = 'Cubic';
Options.Alpha = 4;
Options.Similarity = 'p';
Options.Registration = 'NonRigid';
Options.MaxRef = 5;
Options.Verbose = 0;
validref = false;

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
            validref = true;
        catch
            logging.warn("Can not concatenate images, no external reference used.")
        end
    else
        logging.warn("Can not concatenate images, no external reference used.")
    end
end

% Run MOCO
rectSer = centerCropWindow2d(size(imAll,[1 2]),round(size(imAll,[1 2])/cropfactor));
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
        if validref
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
                        [~, idx] = max(squeeze(mean(Dx_crop, [1,2]))* single(rotMatrix(zOri,3)));

                    case 2
                        Dx_crop = zeros([round(size(imAll,[1 2])/cropfactor),11]);
                        parfor ii = 1:11
                            [~, ~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                        [~, idx] = max(squeeze(mean(Dx_crop, [1,2]))* single(rotMatrix(zOri,3)));

                    case 3
                        [x, y] = meshgrid(1:size(BSer, 2), 1:size(BSer, 1));
                        [xq, yq] = meshgrid(1:0.1:size(BSer, 2), 1:0.1:size(BSer, 1));
                        parfor ii = 1:11
                            BSer_interp(:,:,ii) = interp2(x, y, BSer(:,:,ii+1), xq, yq,'spline');
                        end
                        rectSer_interp = centerCropWindow2d(size(BSer_interp,[1 2]),round(size(BSer_interp,[1 2])/cropfactor));
                        ref_interp = imcrop(BSer_interp(:,:,5),rectSer_interp);
                        parfor ii = 1:11
                            cross_corr = normxcorr2(ref_interp,BSer_interp(:,:,ii));
                            [~, imax] = max(abs(cross_corr(:)));
                            [~, xpeak] = ind2sub(size(cross_corr), imax(1));
                            xshift(ii) = xpeak - (size(BSer_interp,2) + size(ref_interp,2) + 1)/2;
                        end
                        [~, idx] = max(xshift* single(rotMatrix(zOri,3)));

                end
            else
                switch moco
                    case 1
                        [Dx,~] = mocoDisp(BSer(:,:,2:12), 5, param.mocoReg);
                        parfor ii = 1:11
                            Dx_crop(:,:,ii) = imcrop(Dx(:,:,ii),rectSer);
                        end
                        [~, idx] = max(squeeze(mean(Dx_crop, [1,2]))* single(rotMatrix(zOri,3)));

                    case 2
                        Dx_crop = zeros([round(size(imAll,[1 2])/cropfactor),11]);
                        parfor ii = 1:11
                            [~, Dx] = register_images(BSer(:,:,ii+1), BSer(:,:,6), Options);
                            Dx_crop(:,:,ii) = imcrop(Dx,rectSer);
                        end
                        [~, idx] = max(squeeze(mean(Dx_crop, [1,2]))* single(rotMatrix(zOri,3)));

                    case 3
                        [x, y] = meshgrid(1:size(BSer, 2), 1:size(BSer, 1));
                        [xq, yq] = meshgrid(1:0.1:size(BSer, 2), 1:0.1:size(BSer, 1));
                        parfor ii = 1:11
                            BSer_interp(:,:,ii) = interp2(x, y, BSer(:,:,ii+1), xq, yq,'spline');
                        end
                        rectSer_interp = centerCropWindow2d(size(BSer_interp,[1 2]),round(size(BSer_interp,[1 2])/cropfactor));
                        ref_interp = imcrop(BSer_interp(:,:,5),rectSer_interp);
                        parfor ii = 1:11
                            cross_corr = normxcorr2(ref_interp,BSer_interp(:,:,ii));
                            [~, imax] = max(abs(cross_corr(:)));
                            [xpeak, ~] = ind2sub(size(cross_corr), imax(1));
                            xshift(ii) = xpeak - (size(BSer_interp,1) + size(ref_interp,1) + 1)/2;
                        end
                        [~, idx] = max(xshift* single(rotMatrix(zOri,3)));

                end
            end
            idx = idx+1;
        else
            idx = round(nRep/2);
        end

        refIma = imAll(:,:,idx,:);
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
            imDisp(:,:,iOri) = [squeeze(mean(mean(Dy_Ser_crop,1),2))*szPix(1), squeeze(mean(mean(Dx_Ser_crop,1),2))*szPix(2)] * single(rotMatrix);

        case 2
            Dx_Ser_crop = nan([round(size(BSer,[1 2])/cropfactor),nRep]);
            Dy_Ser_crop = nan([round(size(BSer,[1 2])/cropfactor),nRep]);
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
            imDisp(:,:,iOri) = [squeeze(mean(mean(Dy_Ser_crop,1),2))*szPix(1), squeeze(mean(mean(Dx_Ser_crop,1),2))*szPix(2)] * single(rotMatrix);

        case 3
            [x, y] = meshgrid(1:size(BSer, 2), 1:size(BSer, 1));
            [xq, yq] = meshgrid(1:0.1:size(BSer, 2), 1:0.1:size(BSer, 1));
            parfor iRep = 1:size(BSer,3)
                BSer_interp(:,:,iRep) = interp2(x, y, BSer(:,:,iRep), xq, yq,'spline');
            end
            rectSer_interp = centerCropWindow2d(size(BSer_interp,[1 2]),round(size(BSer_interp,[1 2])/cropfactor));
            Iref = imcrop(BSer_interp(:,:,idx),rectSer_interp);
            parfor iRep = 1:size(BSer,3)
                cross_corr = normxcorr2(Iref,BSer_interp(:,:,iRep));
                [ssimval(iRep,iOri), imax] = max(abs(cross_corr(:)));
                [ypeak, xpeak] = ind2sub(size(cross_corr), imax(1));
                yshift(iRep) = ypeak - (size(BSer_interp,1) + size(Iref,1) + 1)/2;
                xshift(iRep) = xpeak - (size(BSer_interp,2) + size(Iref,2) + 1)/2;
                Ireg = imtranslate(BSer(:,:,iRep), [-xshift(iRep)/10 -yshift(iRep)/10], 'FillValues', 0, 'OutputView', 'same');
                Icomb(:,:,iRep) = cat(2, BSer(:,:,iRep), Ireg);
            end
            imDisp(:,:,iOri) = [xshift(:)*szPix(1)/10, yshift(:)*szPix(2)/10] * single(rotMatrix);

    end
    % === MOCO all images use end respiratory frame as reference ===

    % +++ Save MOCOed images +++
%     if ispc
%         clear im
%         figname = sprintf("%s.%s_%s_IMG_MOCO_Ori%i.gif",tmp{11}, tmp{end}, metadata.measurementInformation.protocolName, iOri);
%         for iRep = 1:nRep
%             im = uint8(Icomb(:,:,iRep)/max(Iref(:))*255);
% 
%             if iRep == 1
%                 imwrite(im,fullfile(pwd,'output',figname), 'gif', 'Loopcount', inf);
%             else
%                 imwrite(im,fullfile(pwd,'output',figname),'gif', 'DelayTime', 0.25, 'WriteMode','append');
%             end
%         end
%     end
    % === Save MOCOed images ===

    % +++ Plot SSIM  +++
%     if ispc
%         thrd = min([mean(ssimval(:,iOri),'omitnan') - 3*std(ssimval(:,iOri),[],'omitnan') 2.5*quantile(ssimval(:,iOri), 0.25)-1.5*quantile(ssimval(:,iOri), 0.75)]);
%         fig = figure(99);
%         subplot(double(nOri),1,double(iOri))
%         plot(ssimval(:,iOri),'*')
%         if sum(ssimval(:,iOri) < thrd)
%             hold on
%             line([0 nRep],[thrd thrd],'Color','k','LineStyle','--')
%             hold off
%         end
%         title(sprintf('Ref frame %i, Mean SSIM: %0.2f',idx,mean(ssimval(:,iOri),'omitnan')))
%     end
    % === Plot SSIM ===

    refIma_crop(:,:,iOri) = Iref;
end    % end of count Ori

[~, idx] = sort(mean(ssimval,'omitnan'),'descend');
imshift = squeeze(imDisp(:,:,idx(1)));
imshift(:,~any(imshift,1)) = squeeze(imDisp(:,~any(imshift,1),idx(2)));

if nRep ~= (max(cell2mat(cellfun(@(x) x.head.repetition, group, 'UniformOutput', false))) + 1)
    imshift(1,:) = [];
end

imdata.shiftvec = imshift;
imdata.ref_crop = refIma_crop;
imdata.isFlip = isFlip;
imdata.refIma = refIma;

% Save SSIM plot
% if ispc
%     figname = sprintf("%s.%s_%s_SSIM.png", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
%     saveas(fig, fullfile(pwd,'output',figname))
%     close(fig)
% end

end