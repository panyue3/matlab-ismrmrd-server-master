classdef prompt_kwfilter < handle
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

            % Load training result. If multiple training was done, read in the last file generated
            tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
            filename = sprintf("train_%s.*.mat", tmp{11});
            if ispc
                trainlist = dir(fullfile(pwd,'output',filename));
            elseif isunix
                trainlist = dir(fullfile('/tmp/share/prompt',filename));
            end

            if isempty(trainlist)
                logging.error("Training was not performed.")
            else
                [~,idx] = sort([trainlist.datenum]);
                trainlist = trainlist(idx);
                load(fullfile(trainlist(end).folder,trainlist(end).name), 'net', 'param', 'imdata')
                ref.refIma = imdata.refIma; ref.isFlip = imdata.isFlip;
                clear imdata

                % Check if coils match training series
                coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
                [~, idx] = sort(coils);
                coils = coils(idx);
                if ~matches(cell2str(coils),cell2str(param.coils),"IgnoreCase",true)
                    logging.error("Receiver coils turned on do not match the training series.")
%                     connection.send_text("ERR: Coils need to match the training series.")
                end
            end

            % Init variables
            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            sendRTFB = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTFB'))).value);
            gateWindow = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'PTgateWindow'))).value;
            nTrigs = metadata.encoding.encodingLimits.repetition.maximum+1;
            nImg = (metadata.encoding.encodingLimits.slice.maximum+1) * nTrigs;
            ntClip = 11;
            predshift = []; 
            predskip = [];
            if sendRTFB
                ptGroup = cell(1,ntClip*200*(sysFreeMax+1)); % ismrmrd.Waveform;
                ecgGroup = cell(1,ntClip*10); % ismrmrd.Waveform;
            else
                ptGroup = cell(1,round(1.2*nTrigs*200*(sysFreeMax+1))); % ismrmrd.Waveform;
                ecgGroup = cell(1,round(1.2*nTrigs*10)); % ismrmrd.Waveform;
            end
            imgGroup = cell(1,nImg); % ismrmrd.Image;
            imgCounter = 0;
            ptCounter = 0;
            ecgCounter = 0;
            last_trig = 0;

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
                        if item.head.waveform_id == 16  % ------------------------------------------------------------------------------------------------------------------------ PT waveform
                            if sendRTFB
                                if isempty(ptGroup{end})
                                    ptCounter = ptCounter+1;
                                    ptGroup{ptCounter} = item;
                                else
                                    ptGroup(1:end-1) = ptGroup(2:end);
                                    ptGroup{end} = item;
                                end
                            else
                                ptCounter = ptCounter+1;
                                ptGroup{ptCounter} = item;
                                if ptCounter == numel(ptGroup)
                                    ptGroup{numel(ptGroup)+0.3*nTrigs*200} = [];
                                end
                            end
                            if ptCounter == 1
                                param.startTime = ptGroup{1}.head.time_stamp;
                            end
                        elseif (sysFreeMax && item.head.waveform_id == 3) || (~sysFreeMax && item.head.waveform_id == 0)    % -------------------------------------- ECG waveform
                            if sendRTFB
                                if isempty(ecgGroup{end})
                                    ecgCounter = ecgCounter+1;
                                    ecgGroup{ecgCounter} = item;
                                else
                                    ecgGroup(1:end-1) = ecgGroup(2:end);
                                    ecgGroup{end} = item;
                                end
                            else
                                ecgCounter = ecgCounter+1;
                                ecgGroup{ecgCounter} = item;
                                if ecgCounter == numel(ecgGroup)
                                    ecgGroup{numel(ecgGroup)+0.3*nTrigs*10} = [];
                                end
                            end     

                            trigOccured = (sysFreeMax && sum(item.data(:,2))) || (~sysFreeMax && sum(item.data(:,5)));
                            if trigOccured && (item.head.time_stamp - last_trig)*2.5*10^-3 > 0.5
                                last_trig = item.head.time_stamp;
                                if double(ecgGroup{ecgCounter}.head.time_stamp - param.startTime)*2.5*10^-3 > param.nSecs
                                    if sendRTFB
                                        ptRange = [1, min([ptCounter,ntClip*200*(sysFreeMax+1)])];
                                        ecgRange = [1, min([ecgCounter,ntClip*10])];
                                    else
                                        ptRange = [max([1,ptCounter-ntClip*200*(sysFreeMax+1)+1]), ptCounter];
                                        ecgRange = [max([1,ecgCounter-ntClip*10+1]), ecgCounter];
                                    end

                                    tic
                                    shiftvector = prompt_run_predict(ptGroup(ptRange(1):ptRange(2)), ecgGroup(ecgRange(1):ecgRange(2)), net, param, metadata, logging);
                                    elapsedTime = toc;

                                    % =========== For Phantom Test Only =========== %
                                    % shiftvector = 10*rand(1,3); param.endExp = 10;
                                    % =========== For Phantom Test Only =========== %

                                    % update param.endExp to accommodate respiratory shift
                                    if shiftvector(3) > (param.endExp+gateWindow/2) && any(predshift(max([1,end-19]):end,3)>(param.endExp+gateWindow/2))
                                        param.endExp = shiftvector(3);
                                    elseif size(predskip,1) > 19 && sum(predskip(end-19:end,1)) == 20
                                        param.endExp = max(predshift(end-19:end,3));
                                    end
                                    param.gate = [param.endExp-gateWindow/2, param.endExp+gateWindow/2];

                                    isSkipAcq = logical(shiftvector(3) > param.gate(2) || shiftvector(3) < param.gate(1));
                                    predshift(end+1,:) = shiftvector;
                                    predskip(end+1,:) = [double(isSkipAcq), param.gate];
                                    feedbackData = PTshiftFBData(shiftvector, isSkipAcq, logging);
                                    %feedbackData = PTshiftFBData([0 0 shiftvector(3)], isSkipAcq, logging);
                                    logging.debug("Predicted shift dX: %.6f, dY: %.6f, dZ: %.6f. Skip: %i. -- Time used: %.3f.", feedbackData.shiftVec(1), feedbackData.shiftVec(2), feedbackData.shiftVec(3), isSkipAcq, elapsedTime)

                                else % PT samples not sufficient for prediction
                                    param.gate = [param.endExp-gateWindow/2, param.endExp+gateWindow/2];
                                    predshift(end+1,:) = nan(1,3);
                                    predskip(end+1,:) = [1, param.gate];
                                    feedbackData = PTshiftFBData(zeros(1,3), true, logging);
                                    logging.debug("Collecting PT data, dX: NaN, dY: NaN, dZ: NaN. Skip: true.")

                                end

                                if sendRTFB
                                    % Send shift vector through Feedback
                                    connection.send_feedback('PTShift', feedbackData);
                                end
                                
                            end     % ecg trigger occured

                        end     % ------------------------------------------------------------------------------------------------------------------------------------------------- END waveform

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
                if ~exist('info','var')
                    load(fullfile(trainlist(end).folder,trainlist(end).name), 'info')
                end

                % ----------------------------------------------------------
                % Image data group
                % ----------------------------------------------------------
                if ~isempty(imgGroup)                
                    if ~sendRTFB && ~isempty(imgGroup{1})
                        logging.info("Processing a group of images (untriggered)")
                        [image, imdata] = prompt_process_images(imgGroup(1:imgCounter), metadata, logging, ref);
                        logging.debug("Sending image to client");
                        connection.send_image(image);
                    end
                end

                % ----------------------------------------------------------
                % Waveform data group
                % ----------------------------------------------------------
                if ~isempty(ptGroup) && ~isempty(ecgGroup)
                    if ~sendRTFB && exist('param','var') && ~isempty(ptGroup{1}) && ~isempty(ecgGroup{1})
                        logging.info("Processing a group of PT data (untriggered)")
                        ptdata = prompt_process_waveform(ptGroup(1:ptCounter), ecgGroup(1:ecgCounter), metadata, logging, param);
                    end
                    ptGroup = cell(1,0);
                    ecgGroup = cell(1,0);
                elseif ~isempty(ptGroup)
                    ptGroup = cell(1,0);
                elseif ~isempty(ecgGroup)
                    ecgGroup = cell(1,0);
                end

                % ----------------------------------------------------------
                % Save data and generate plots
                % ----------------------------------------------------------
                filename = sprintf("%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
                if ispc
                    filename = fullfile(pwd,'output',filename);
                elseif isunix
                    filename = fullfile('/tmp/share/prompt',filename);
                end

                if exist('predshift','var')
                    param.predskip = predskip;
                    if exist('imdata','var')
                        save(filename,'imdata', 'predshift', 'predskip', 'param');
                        image = prompt_plot_predict(imdata.shiftvec, predshift, param, info, metadata, logging);
                        logging.debug("Sending predict image to client");
                        connection.send_image(image);
                    else
                        save(filename,'predshift', 'predskip');
                        if ~sendRTFB
                            image = prompt_plot_predict([], predshift, param, info, metadata, logging);
                            logging.debug("Sending predict image to client");
                            connection.send_image(image);
                        end
                    end

                    if exist('ptdata','var')
                        save(filename, 'ptdata','-append');
                    end
                else
                    logging.warn("Predicted shift data not found")
                end

                % ----------------------------------------------------------
                % KW filtering
                % ----------------------------------------------------------
                if ~isempty(imgGroup)
                    logging.info("Processing a group of images for KW filtering")
                    image = kwfilter_process_images(imgGroup(1:imgCounter), metadata, logging);
                    logging.debug("Sending filtered image to client");
                    connection.send_image(image);
                    imgGroup = cell(1,0);
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
