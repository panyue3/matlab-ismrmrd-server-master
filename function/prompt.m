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
                        % Accumulate all imaging readouts in a group
                        if (~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_NOISE_MEASUREMENT)    && ...
                            ~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_PHASECORR_DATA)       && ...
                            ~item.head.flagIsSet(item.head.FLAGS.ACQ_IS_PARALLEL_CALIBRATION)       )
                                acqGroup{end+1} = item;
                        end

                        % When this criteria is met, run process_raw() on the accumulated
                        % data, which returns images that are sent back to the client.
                        if item.head.flagIsSet(item.head.FLAGS.ACQ_LAST_IN_MEASUREMENT)
                            logging.info("Do nothing to k-space data")
                            acqGroup = cell(1,0);
                        end

                    % ----------------------------------------------------------
                    % Image data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
                        % Only process magnitude images -- send phase images back without modification
                        if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                            imgGroup{end+1} = item;
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

            % Process any remaining groups of raw or image data.  This can
            % happen if the trigger condition for these groups are not met.
            % This is also a fallback for handling image data, as the last
            % image in a series is typically not separately flagged.
            if ~isempty(acqGroup)
                logging.info("Do nothing to k-space data (untriggered)")
                acqGroup = cell(1,0);
            end

            if ~isempty(imgGroup)
                logging.info("Processing a group of images (untriggered)")
                [image, imshift] = obj.process_images(imgGroup, config, metadata, logging);
                logging.debug("Sending image to client");
                connection.send_image(image);
                %------ Temporarily used as wavGroup for image header ------%
                saveHead = imgGroup(1);  
                %------ Remember to delete when wavGroup available --------%
                imgGroup = cell(1,0);
            else
                logging.warn("Image was not received.")
            end

%             if ~isempty(wavGroup)
%                 logging.info("Processing a group of PT data (untriggered)")
%                 [image, ptdata] = obj.process_waveform(wavGroup, config, metadata, logging);
%                 logging.debug("Sending image to client");
%                 connection.send_image(image);
%                 wavGroup = cell(1,0);
%             else
%                 logging.warn("PT data was not received.")
%             end
            [image, ptdata] = obj.process_waveform(saveHead, config, metadata, logging);
            logging.debug("Sending image to client");
            connection.send_image(image);

            % Save image and pt data and train network
            if exist('imshift','var') && exist('ptdata','var')
                tmp = split(metadata.measurementInformation.frameOfReferenceUID,'.');
                filename = sprintf("%s_%s.mat",metadata.measurementInformation.protocolName, tmp{11});
                if ispc
                    save(fullfile(pwd,'output',filename),'imshift', 'ptdata');
                elseif isunix
                    save(fullfile('/tmp/share',filename),'imshift', 'ptdata');
                end

                % Run prediction
                logging.info("Training network")
%                 runPredict(imshift, ptdata, logging);
            else
                logging.error("Processed PT or image shift data not found")
            end

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_IMAGES
        function [image, imshift] = process_images(obj, group, config, metadata, logging)

            % Calculate image shift
            imshift = calcImageShift(group, metadata, logging);

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

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            data = uint16(255 - rgb2gray(imread(fullfile(pwd,'output','Disp.png'))))';
            image = ismrmrd.Image(data);


            % Copy original image header, but keep the new data_type
            data_type = image.head.data_type;
            image.head = group{1}.head;
            image.head.data_type = data_type;
            image.head.matrix_size = size(data, [1 2 3]);

            % Add to ImageProcessingHistory
            meta = ismrmrd.Meta.deserialize(group{1}.attribute_string);
            meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'Cardiac Shift');
            meta = ismrmrd.Meta.appendValue(meta, 'WindowCenter', 40);
            meta = ismrmrd.Meta.appendValue(meta, 'WindowWidth', 80);
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

        end     % end of process_images()

        %% PROCESS_IMAGES
        function [image, ptdata] = process_waveform(obj, group, config, metadata, logging)

            % Read raw PT 
            if ispc
                ptdata.rawdata = load('C:\MIDEA\NXVA31A_176478\src\MrVista\Simu\PTdata.txt');
            elseif isunix
                ptdata.rawdata = load('\tmp\share\PTdata.txt');
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

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            data = uint16(255 - rgb2gray(imread(fullfile(pwd,'output','PT.png'))))';
            image = ismrmrd.Image(data);

            % Copy original image header, but keep the new data_type
            data_type = image.head.data_type;
            image.head = group{1}.head;
            image.head.data_type = data_type;
            image.head.matrix_size = size(data, [1 2 3]);

            % Add to ImageProcessingHistory
            meta = ismrmrd.Meta.deserialize(group{1}.attribute_string);
            meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'Processed PT');
            meta = ismrmrd.Meta.appendValue(meta, 'WindowCenter', 40);
            meta = ismrmrd.Meta.appendValue(meta, 'WindowWidth', 80);
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

        end     % end of process_waveform()

    end
end
