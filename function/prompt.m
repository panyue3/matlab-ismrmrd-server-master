classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)
            logging.info('Config: \n%s', config);

            % Check if output folders exist
            if ~exist('output', 'dir')
                mkdir('output')
            end
            if isunix && ~exist('/tmp/share', 'dir')
                mkdir('tmp/share')
            end

            if contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true)
                runTraining = true;
            else
                runTraining = false;
            end

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
            wavGroup = cell(1,0); % ismrmrd.Waveform;
            try
                while true
                    item = next(connection);

                    % ----------------------------------------------------------
                    % Raw k-space data messages
                    % ----------------------------------------------------------
                    if isa(item, 'ismrmrd.Acquisition')
                        logging.info("Do nothing to k-space data")

                    % ----------------------------------------------------------
                    % Image data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
                        if runTraining
                            % Only process magnitude images -- send phase images back without modification
                            if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                                imgGroup{end+1} = item;
                            end
                        else
                            logging.info("Running image shift prediction...");
                            shiftvector = obj.run_predict(wavGroup, metadata, logging);

                            % ++++++++++ SEND SHIFTVECTOR TO SEQUENCE ++++++++++ %
                        end

                    % ----------------------------------------------------------
                    % Waveform data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Waveform')
                        wavGroup{end+1} = item;

                    elseif isempty(item)
                        break;

                    else
                        logging.error("Unhandled data type: %s", class(item))
                    end
                end
            catch ME
                logging.error(sprintf('%s\nError in %s (%s) (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ME.stack(1).('line')));
            end

            if runTraining
                % ----------------------------------------------------------
                % Raw k-space data group
                % ----------------------------------------------------------
                if ~isempty(acqGroup)
                    logging.info("Do nothing to k-space data (untriggered)")
                    acqGroup = cell(1,0);
                end

                % ----------------------------------------------------------
                % Image data group
                % ----------------------------------------------------------
                if ~isempty(imgGroup)
                    logging.info("Processing a group of images (untriggered)")
                    [image, imshift] = obj.process_images(imgGroup, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                    % Save header info for image generation
                    info.head = imgGroup{1}.head;
                    info.attribute_string = imgGroup{1}.attribute_string;
                    %------ Temporarily used as wavGroup for image header ------%
                    saveHead = imgGroup(1);
                    %------ Remember to delete when wavGroup available --------%
                    imgGroup = cell(1,0);
                else
                    logging.warn("Image was not received.")
                end

                % ----------------------------------------------------------
                % Waveform data group
                % ----------------------------------------------------------
                %             if ~isempty(wavGroup)
                %                 logging.info("Processing a group of PT data (untriggered)")
                %                 [image, ptdata] = obj.process_waveform(wavGroup, metadata, logging);
                %                 logging.debug("Sending image to client");
                %                 connection.send_image(image);
                %                 wavGroup = cell(1,0);
                %             else
                %                 logging.warn("PT data was not received.")
                %             end
                [image, ptdata] = obj.process_waveform(saveHead, metadata, logging);
                logging.debug("Sending image to client");
                connection.send_image(image);

                % ----------------------------------------------------------
                % Run network training
                % ----------------------------------------------------------
                if exist('imshift','var') && exist('ptdata','var')
                    image = obj.train_network(imshift, ptdata, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Processed PT or image shift data not found")
                end
            end     % if runTraining

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_IMAGES
        function [image, imshift] = process_images(obj, group, metadata, logging)

            % Calculate image shift
            imshift = calculateImageShift(group, metadata, logging);

            % Save figure to output folder
            fig = figure;
            hold on
            plot(imshift(:,1),'k'); plot(imshift(:,2),'k--'); plot(imshift(:,3),'k:');
            xlim([0 size(imshift,1)]);
            ylabel('Displacement (mm)'); title('Image Disp');
            legend('dX','dY','dZ','Location','southoutside','NumColumns',3);
            hold off
            saveas(fig, fullfile(pwd,'output','Disp.png'))
            close(fig)

            data = uint16(255 - rgb2gray(imread(fullfile(pwd,'output','Disp.png'))))';
            image = obj.pack_image(data, group{1}.head, group{1}.attribute_string);

        end     % end of process_images()

        %% PROCESS_WAVEFORM
        function [image, ptdata] = process_waveform(obj, group, metadata, logging)

            % Read raw PT
            if ispc
                ptdata.rawdata = load('C:\MIDEA\NXVA31A_176478\src\MrVista\Simu\PTdata.txt');
            elseif isunix
                ptdata.rawdata = load('/tmp/share/PTdata.txt');
            end

            % Process PT
            [ptdata.data, ptdata.time, ptdata.param] = processPT(ptdata.rawdata, logging);

            % Save figure to output folder
            fig = figure;
            hold on
            plot(ptdata.time, ptdata.data(:,1),'k'); plot(ptdata.time, ptdata.data(:,2),'k--');
            xlim([0 max(ptdata.time)]);
            title('First channel PT');
            legend('Real','Imaginary','Location','southoutside','NumColumns',2);
            hold off
            saveas(fig, fullfile(pwd,'output','PT.png'))
            close(fig)

            data = uint16(255 - rgb2gray(imread(fullfile(pwd,'output','PT.png'))))';
            image = obj.pack_image(data, group{1}.head, group{1}.attribute_string);

        end     % end of process_waveform()

        %% TRAIN_NETWORK
        function image = train_network(obj, imshift, ptdata, info, metadata, logging)

            tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
            filename = sprintf("%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
            if ispc
                save(fullfile(pwd,'output',filename),'imshift', 'ptdata');
            elseif isunix
                save(fullfile('/tmp/share',filename),'imshift', 'ptdata');
            end

            % Run training
            ptdata.param.cor = sign(corr(imshift(:,3),ptdata.data(ptdata.param.pk,:)));
            ptdata.data = ptdata.data * diag(ptdata.param.cor);

            logging.info("Training network...")
            [net, param] = runTraining(imshift, ptdata, logging);
            param.coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
            [~, idx] = sort(param.coils);
            param.coils = param.coils(idx);
            if ispc
                save(fullfile(pwd,'output',filename),'net', 'param', '-append');
            elseif isunix
                save(fullfile('/tmp/share',filename),'net', 'param', '-append');
            end

            data = uint16(255 - rgb2gray(imread(param.figName)))';
            image = obj.pack_image(data, info.head, info.attribute_string);

        end     % end of train_network()

        %% RUN_PREDICT
        function shiftvector = run_predict(obj, group, metadata, logging)

            % Load training result. If multiple training was done, read in the last file generated
            tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
            filename = sprintf("%s.*.mat", tmp{11});
            if ispc
                trainlist = dir(fullfile(pwd,'output',filename));
            elseif isunix
                trainlist = dir(fullfile('/tmp/share',filename));
            end

            if isempty(trainlist) || ~contains([trainlist.name],'train', 'IgnoreCase', true)
                logging.error("Training was not performed.")
            else
                [~,idx] = sort([trainlist.datenum]);
                trainlist = trainlist(idx);
                while ~contains(trainlist(end).name,'train', 'IgnoreCase', true)
                    trainlist(end) = [];
                end
                load(fullfile(trainlist(end).folder,trainlist(end).name), 'net', 'param')

                % Check if coils match training series
                coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
                [~, idx] = sort(coils);
                coils = coils(idx);
                if ~matches(cell2str(coils),cell2str(param.coils),"IgnoreCase",true)
                    logging.error("Receiver coils turned on do not match the training series.")
                end

                % ++++++++++ PROCESS PT +++++++++%

                % ++++++++++ RUN PREDICTION +++++++++%


            end

        end     % end of run_predict()

        %% PACK_IMAGE
        function image = pack_image(obj, data, head, attribute_string)

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            image = ismrmrd.Image(data);

            % Copy original image header, but keep the new data_type
            data_type = image.head.data_type;
            image.head = head;
            image.head.data_type = data_type;
            image.head.matrix_size = size(data, [1 2 3]);

            % Add to ImageProcessingHistory
            meta = ismrmrd.Meta.deserialize(attribute_string);
            meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'PROMPT');
            meta = ismrmrd.Meta.appendValue(meta, 'WindowCenter', 40);
            meta = ismrmrd.Meta.appendValue(meta, 'WindowWidth', 80);
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

        end % end of pack_image

    end
end
