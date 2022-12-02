classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)
            logging.info('Config: \n%s', config);

            % Metadata should be MRD formatted header, but may be a string
            % if it failed conversion earlier
            try
                logging.info("Incoming dataset contains %d encodings", numel(metadata.encoding))
                logging.info("First encoding is of type '%s', with field of view of (%g x %g x %g)mm^3, matrix size of (%g x %g x %g), and %g coils", ...
                    metadata.encoding(1).trajectory, ...
                    metadata.encoding(1).encodedSpace.fieldOfView_mm.x, ...
                    metadata.encoding(1).encodedSpace.fieldOfView_mm.y, ...
                    metadata.encoding(1).encodedSpace.fieldOfView_mm.z, ...
                    metadata.encoding(1).encodedSpace.matrixSize.x, ...
                    metadata.encoding(1).encodedSpace.matrixSize.y, ...
                    metadata.encoding(1).encodedSpace.matrixSize.z, ...
                    metadata.acquisitionSystemInformation.receiverChannels)
            catch
                logging.info("Improperly formatted metadata: \n%s", metadata)
            end

            % Continuously parse incoming data parsed from MRD messages
            acqGroup = cell(1,0); % ismrmrd.Acquisition;
            imgGroup = cell(1,0); % ismrmrd.Image;
            try
                while true
                    item = next(connection);

                    % ----------------------------------------------------------
                    % Raw k-space data messages
                    % ----------------------------------------------------------
                    if isa(item, 'ismrmrd.Acquisition')
                        % Accumulate all imaging readouts in a group
                        if (~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_NOISE_MEASUREMENT)    && ...
                                ~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_PHASECORR_DATA)       && ...
                                ~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_PARALLEL_CALIBRATION)       )
                            acqGroup{end+1} = item;
                        end

                        % When this criteria is met, run process_raw() on the accumulated
                        % data, which returns images that are sent back to the client.
                        if item.head.flagIsSet(item.head.FLAGS.ACQ_LAST_IN_SLICE)
                            logging.info("Processing a group of k-space data")
                            image = obj.process_raw(acqGroup, config, metadata, logging);
                            logging.debug("Sending image to client")
                            connection.send_image(image);
                            acqGroup = {};
                        end

                        % ----------------------------------------------------------
                        % Image data messages
                        % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
                        % Only process magnitude images -- send phase images back without modification
                        if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                            imgGroup{end+1} = item;
                        else
                            connection.send_image(item);
                            continue
                        end

                        % When this criteria is met, run process_group() on the accumulated
                        % data, which returns images that are sent back to the client.
                        % TODO: logic for grouping images
                        if false
                            logging.info("Processing a group of images")
                            image = obj.process_images(imgGroup, config, metadata, logging);
                            logging.debug("Sending image to client")
                            connection.send_image(image);
                            imgGroup = cell(1,0);
                        end

                    elseif isempty(item)
                        break;

                    else
                        logging.error("Unhandled data type: %s", class(item))
                    end
                end
            catch ME
                logging.error(sprintf('%s\nError in %s (%s) (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ME.stack(1).('line')));
            end

            % Process any remaining groups of raw or image data.  This can
            % happen if the trigger condition for these groups are not met.
            % This is also a fallback for handling image data, as the last
            % image in a series is typically not separately flagged.
            if ~isempty(acqGroup)
                logging.info("Processing a group of k-space data (untriggered)")
                image = obj.process_raw(acqGroup, config, metadata, logging);
                logging.debug("Sending image to client")
                connection.send_image(image);
                acqGroup = cell(1,0);
            end

            if ~isempty(imgGroup)
                logging.info("Processing a group of images (untriggered)")
                imshift = obj.process_images(imgGroup, config, metadata, logging);

                % Save displacement data and figure to output folder
                tmp = split(metadata.measurementInformation.frameOfReferenceUID,'.');
                filename = sprintf("%s_%s.mat",metadata.measurementInformation.protocolName, tmp{11});
                logging.debug("Saving displacement data.");
                save(fullfile(pwd,'output',filename),'imshift');
                filename = sprintf("%s_%s.png",metadata.measurementInformation.protocolName, tmp{11});
                fig = figure;
                plot(imshift); ylabel('Disp data'); legend('dX','dY','dZ'); title('Image Disp');
                saveas(fig, fullfile(pwd,'output',filename))
                close(fig)

                %                 connection.send_image(image);
                imgGroup = cell(1,0);
            end

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_RAW
        function image = process_raw(obj, group, config, metadata, logging)
            % This function assumes that the set of raw data belongs to a
            % single image.  If there's >1 phases, echos, sets, etc., then
            % either the call to this function from process() needs to be
            % adjusted or this code must be modified.

            % Format data into a single [RO PE cha] array
            ksp = cell2mat(permute(cellfun(@(x) x.data, group, 'UniformOutput', false), [1 3 2]));
            ksp = permute(ksp, [1 3 2]);

            % Fourier Transform
            img = fftshift(fft2(ifftshift(ksp)));

            % Sum of squares coil combination
            img = sqrt(sum(abs(img).^2,3));

            % Remove phase oversampling
            img = img(round(size(img,1)/4+1):round(size(img,1)*3/4),:);
            logging.debug("Image data is size %d x %d after coil combine and phase oversampling removal", size(img))

            % Normalize and convert to short (int16)
            img = img .* (32767./max(img(:)));
            img = int16(round(img));

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            image = ismrmrd.Image(img);

            % Find the center k-space index
            kspace_encode_step_1 = cellfun(@(x) x.head.idx.kspace_encode_step_1, group);
            centerLin            = cellfun(@(x) x.head.idx.user(6),              group);
            centerIdx = find(kspace_encode_step_1 == centerLin, 1);

            % Copy the relevant AcquisitionHeader fields to ImageHeader
            image.head.fromAcqHead(group{centerIdx}.head);

            % field_of_view is mandatory
            image.head.field_of_view  = single([metadata.encoding(1).reconSpace.fieldOfView_mm.x ...
                metadata.encoding(1).reconSpace.fieldOfView_mm.y ...
                metadata.encoding(1).reconSpace.fieldOfView_mm.z]);

            % Set ISMRMRD Meta Attributes
            meta = struct;
            meta.DataRole               = 'Image';
            meta.ImageProcessingHistory = 'MATLAB';
            meta.WindowCenter           = uint16(16384);
            meta.WindowWidth            = uint16(32768);
            meta.ImageRowDir            = group{centerIdx}.head.read_dir;
            meta.ImageColumnDir         = group{centerIdx}.head.phase_dir;

            % set_attribute_string also updates attribute_string_len
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

            % Call process_image to do actual image inversion
            image = obj.process_images({image});
        end     % end of process_raw()

        %% PROCESS_IMAGES
        function imshift = process_images(obj, group, config, metadata, logging)
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

            % Run MOCO
            rectSer = centerCropWindow2d(size(imAll,[1 2]),round(size(imAll,[1 2])/3));
            imshift = nan(nRep,3);
            nmse = nan(nOri, nRep);
            for iOri = 1:nOri
                % +++ Find image orientation +++
                [readphaseDir, readphaseOri] = max(abs([group{iOri}.head.read_dir; group{iOri}.head.phase_dir]),[],2);
                if sum(readphaseDir) ~= 2
                    logging.info("Images acquired are not in true sagital, coronal, or axial plane.")
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
                % === Save MOCOed images ===

                % +++ Plot NMSE  +++
                nmse(iOri,1) = nan;
                fig = figure(1);
                subplot(double(nOri),1,double(iOri))
                plot(nmse(iOri,:))
                title(sprintf('Ref frame %i, Mean NMSE x 1000: %0.2f',idx,mean(nmse(iOri,:),'omitnan')*1000))
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
            filename = sprintf("%s_%s_NMSE.png",metadata.measurementInformation.protocolName, tmp{11});
            saveas(fig, fullfile(pwd,'output',filename))
            close(fig)

        end     % end of process_images()
    end
end
