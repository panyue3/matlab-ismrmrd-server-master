classdef prompt_calibrate < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)

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

            % Check if output folders exist
            if ~exist('output', 'dir')
                mkdir('output')
            end
            if isunix && ~exist('/tmp/share/prompt', 'dir')
                mkdir('/tmp/share/prompt')
            end

            % Create parallel pool
            if isempty(gcp('nocreate'))
                parpool('local','SpmdEnabled',false)
            end

            % Init variables
            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            nTrigs = metadata.encoding.encodingLimits.repetition.maximum+1;
            nImg = (metadata.encoding.encodingLimits.slice.maximum+1) * nTrigs;
            imgGroup = cell(1,nImg); % ismrmrd.Image;
            ptGroup = cell(1,round(1.2*nTrigs*200*(sysFreeMax+1))); % ismrmrd.Waveform;
            ecgGroup = cell(1,round(1.2*nTrigs*10)); % ismrmrd.Waveform;
            imgCounter = 0;
            ptCounter = 0;
            ecgCounter = 0;

 %% Continuously parse incoming data parsed from MRD messages
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
                        if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                            imgCounter = imgCounter+1;
                            imgGroup{imgCounter} = item;
                            if ~exist('info','var')
                                % Save header info for image generation
                                info.head = item.head;
                                info.attribute_string = item.attribute_string;
                            end
                        end

                    % ----------------------------------------------------------
                    % Waveform data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Waveform') 
                        if item.head.waveform_id == 16
                            ptCounter = ptCounter+1;
                            ptGroup{ptCounter} = item;
                            if ptCounter == numel(ptGroup)
                                ptGroup{numel(ptGroup)+0.3*nTrigs*200} = [];
                            end
                        elseif (sysFreeMax && item.head.waveform_id == 3) || (~sysFreeMax && item.head.waveform_id == 0)
                            ecgCounter = ecgCounter+1;
                            ecgGroup{ecgCounter} = item;
                            if ecgCounter == numel(ecgGroup)
                                ecgGroup{numel(ecgGroup)+0.3*nTrigs*10} = [];
                            end
                        end     % if waveform is ecg or pt

                    % ----------------------------------------------------------
                    % Empty messages
                    % ----------------------------------------------------------
                    elseif isempty(item)
                        break;

                    else
                        logging.error("Unhandled data type: %s", class(item))
                    end
                end
            catch ME
                logging.error(sprintf('%s\nError in %s (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('line')));
            end % done collecting data
%%
            try
                % ----------------------------------------------------------
                % Image data group
                % ----------------------------------------------------------
                if ~isempty(imgGroup) && ~isempty(imgGroup{1})
                    logging.info("Processing a group of images (untriggered)")
                    [image, imdata] = prompt_process_images(imgGroup(1:imgCounter), metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                    imgGroup = cell(1,0);
                end

                % ----------------------------------------------------------
                % Waveform data group
                % ----------------------------------------------------------
                if ~isempty(ptGroup) && ~isempty(ecgGroup) && ~isempty(ptGroup{1}) && ~isempty(ecgGroup{1})
                    logging.info("Processing a group of PT data (untriggered)")
                    ptdata = prompt_process_waveform(ptGroup(1:ptCounter), ecgGroup(1:ecgCounter), metadata, logging);
                    ptGroup = cell(1,0);
                    ecgGroup = cell(1,0);
                elseif ~isempty(ptGroup)
                    ptGroup = cell(1,0);
                elseif ~isempty(ecgGroup)
                    ecgGroup = cell(1,0);
                end

                % ----------------------------------------------------------
                % Train network
                % ----------------------------------------------------------
                if exist('imdata','var') && exist('ptdata','var')
                    image = prompt_train_network(imdata, ptdata, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Processed PT or image shift data not found")
                end
            catch ME
                logging.error(sprintf('%s\nError in %s (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('line')));
            end
%%
            % Reset gpu device
            if gpuDeviceCount
                gpuDevice([]);
            end
            delete(gcp('nocreate'));

            connection.send_close();

            return
        end  % end of process()

    end
end
