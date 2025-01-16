classdef prompt_map < handle
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

            % Check config parameters
            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            sendRTFB = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTFB'))).value);

            if sendRTFB
                % Send feedback once to open the connection
                feedbackData = PTshiftFBData(zeros(1,3), true, logging);
                connection.send_feedback('PTShift', feedbackData);
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
                error("Training was not performed.")
            else
                [~,idx] = sort([trainlist.datenum]);
                trainlist = trainlist(idx);
                load(fullfile(trainlist(end).folder,trainlist(end).name), 'net', 'param', 'imdata')
                if sendRTFB
                    isPhantom = imdata.respRange < 1;
                    clear imdata
                else
                    ref.refIma = imdata.refIma; ref.isFlip = imdata.isFlip;
                    clear imdata
                end

                % Check if coils match training series
                coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
                [~, idx] = sort(coils);
                coils = coils(idx);
                if ~matches(cell2str(coils),cell2str(param.coils),"IgnoreCase",true)
                    error("ERR: Coils need to match the training series.")
                end
            end

            % Init variables
            gateWindow = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'PTgateWindow'))).value;
            if ~gateWindow
                if exist('isPhantom','var') && isPhantom
                    gateWindow = 15;
                else
                    gateWindow = param.defaultWin*1.5; % +-75% respiration range in training dataset
                end
                logging.info("Gating window is not set, usiong default %0.1f mm.", gateWindow)
            end
            logging.info("Accepting images between [%0.1f, %0.1f]mm.", param.endExp-gateWindow/2, param.endExp+gateWindow/2)
            nTrigs = (metadata.encoding.encodingLimits.average.maximum+1)*(metadata.encoding.encodingLimits.repetition.maximum+1)*(metadata.encoding.encodingLimits.set.maximum+1);
            ntClip = 11;
            predshift = []; 
            predskip = [];
            if sendRTFB
                ptGroup = cell(1,ntClip*200*(sysFreeMax+1)); % ismrmrd.Waveform;
                ecgGroup = cell(1,ntClip*10); % ismrmrd.Waveform;

                % Init prompt_run_predict to avoid delay in first prediction
                tic
                prompt_run_predict([], [], net, param, metadata, logging);
                elapsedTime = toc;
                logging.debug("Initiate prediction. -- Time used: %.3f.", elapsedTime)
            else
                ptGroup = cell(1,round(1.2*nTrigs*200*(sysFreeMax+1))); % ismrmrd.Waveform;
                ecgGroup = cell(1,round(1.2*nTrigs*10)); % ismrmrd.Waveform;
            end
            imgGroup = cell(1,0); % ismrmrd.Image;
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
                        if ~exist('info','var')
                            % Save header info for image generation
                            info.head = item.head;
                            info.attribute_string = item.attribute_string;
                        end
                        logging.info("Do nothing to image data")

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
                            if trigOccured
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

                                    predshift(end+1,:) = shiftvector;
                                    % =========== For Phantom Test Only =========== %
                                    if exist('isPhantom','var') && isPhantom
                                        logging.info('Phantom image detected, using random value between 0 to 10 with endExp = 10.')
                                        shiftvector = 10*rand(1,3); param.endExp = 10;
                                    end
                                    % =========== For Phantom Test Only =========== %

                                    % update param.endExp to accommodate respiratory shift
                                    if shiftvector(3) > (param.endExp+gateWindow/2) && any(predshift(max([1,end-19]):end,3)>(param.endExp+gateWindow/2))
                                        logging.info("Changing end expiratory level: %0.2f --> %0.2f", param.endExp, shiftvector(3))
                                        param.endExp = shiftvector(3);
                                        save(fullfile(trainlist(end).folder,trainlist(end).name), 'param','-append')
                                    elseif size(predskip,1) > 19 && sum(predskip(end-19:end,1)) == 20
                                        logging.info("Changing end expiratory level: %0.2f --> %0.2f", param.endExp, max(predshift(end-19:end,3)))
                                        param.endExp = max(predshift(end-19:end,3));
                                        save(fullfile(trainlist(end).folder,trainlist(end).name), 'param','-append')
                                    end
                                    gateRange = [param.endExp-gateWindow/2, param.endExp+gateWindow/2];

                                    isSkipAcq = logical(shiftvector(3) > gateRange(2) || shiftvector(3) < gateRange(1));
                                    predskip(end+1,:) = [double(isSkipAcq), gateRange];
                                    feedbackData = PTshiftFBData(shiftvector, isSkipAcq, logging);
                                    logging.debug("Predicted shift dX: %.6f, dY: %.6f, dZ: %.6f. Skip: %i. -- Time used: %.3f.", feedbackData.shiftVec(1), feedbackData.shiftVec(2), feedbackData.shiftVec(3), isSkipAcq, elapsedTime)

                                    if sendRTFB
                                        % Send shift vector through Feedback
                                        connection.send_feedback('PTShift', feedbackData);
                                    end

                                else % PT samples not sufficient for prediction
                                    gateRange = [param.endExp-gateWindow/2, param.endExp+gateWindow/2];
                                    predshift(end+1,:) = nan(1,3);
                                    predskip(end+1,:) = [1, gateRange];
                                    feedbackData = PTshiftFBData(zeros(1,3), true, logging);
                                    logging.debug("Collecting PT data, dX: NaN, dY: NaN, dZ: NaN. Skip: true.")

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
                cStr = cat(1, sprintf('%s\n', ME.message), arrayfun(@(x) sprintf('  In %s (line %d)\n', x.name, x.line), ME.stack, 'UniformOutput', false));
                str = [cStr{:}];
                logging.error(str);
            end % done collecting data
%%
            try
                if ~exist('info','var')
                    load(fullfile(trainlist(end).folder,trainlist(end).name), 'info')
                end

                pks = findpeaks(predshift(:,3));
                if numel(pks) > 3
                    newEndExp = median(pks);
                    if newEndExp < param.endExp && (param.endExp-newEndExp) < 1.5
                        logging.info("New end expiratory level computed: %0.2f --> %0.2f", param.endExp, newEndExp)
                        param.endExp =newEndExp;
                        save(fullfile(trainlist(end).folder,trainlist(end).name), 'param','-append')
                    end
                end

                % ----------------------------------------------------------
                % Image data group
                % ----------------------------------------------------------
                if ~isempty(imgGroup)
                    if ~sendRTFB && ~isempty(imgGroup{1}) && ~isunix
                        logging.info("Processing a group of images (untriggered)")
                        [image, imdata] = prompt_process_images(imgGroup(1:imgCounter), metadata, logging, ref);
                        logging.debug("Sending image to client");
                        connection.send_image(image);
                    end
                    imgGroup = cell(1,0);
                end

                % ----------------------------------------------------------
                % Waveform data group
                % ----------------------------------------------------------
                if ~isempty(ptGroup) && ~isempty(ecgGroup)
                    if ~sendRTFB && exist('param','var') && ~isempty(ptGroup{1}) && ~isempty(ecgGroup{1}) && ~isunix
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
                        if ~sendRTFB && ~isunix
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
            catch ME
                cStr = cat(1, sprintf('%s\n', ME.message), arrayfun(@(x) sprintf('  In %s (line %d)\n', x.name, x.line), ME.stack, 'UniformOutput', false));
                str = [cStr{:}];
                logging.error(str);
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
