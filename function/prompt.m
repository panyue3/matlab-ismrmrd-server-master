classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)

            % Check if output folders exist
            if ~exist('output', 'dir')
                mkdir('output')
            end
            if isunix && ~exist('/tmp/share/prompt', 'dir')
                mkdir('/tmp/share/prompt')
            end

            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            runTraining = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTcalibrate'))).value); %contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true);
            sendRTFB = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTFB'))).value);
            gateWindow = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'PTgateWindow'))).value;
            nTrigs = metadata.encoding.encodingLimits.repetition.maximum+1;
            nImg = (metadata.encoding.encodingLimits.slice.maximum+1) * nTrigs;

            % check if training was done before prediction
            if ~runTraining
                predshift = []; predskip = [];

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
                        connection.send_text("ERR: Coils need to match the training series.")
                    end
                end
            else
                if isempty(gcp('nocreate'))
                    parpool('local','SpmdEnabled',false)
                end
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
            imgGroup = cell(1,nImg); % ismrmrd.Image;
            imgCounter = 0;
            ptGroup = cell(1,0); % ismrmrd.Waveform;
            ecgGroup = cell(1,0); % ismrmrd.Waveform;
            last_trig = 0;
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
                            if ~sendRTFB && (runTraining || contains(metadata.measurementInformation.protocolName,'test', 'IgnoreCase', true))
                                imgCounter = imgCounter+1;
                                imgGroup{imgCounter} = item;
                            end
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
                            ptGroup{end+1} = item;
                        elseif (sysFreeMax && item.head.waveform_id == 3) || (~sysFreeMax && item.head.waveform_id == 0)
                            ecgGroup{end+1} = item;                            
                            trigOccured = (sysFreeMax && sum(item.data(:,2))) || (~sysFreeMax && sum(item.data(:,5)));
                            if ~runTraining && trigOccured && (item.head.time_stamp - last_trig)*2.5*10^-3 > 0.5
                                last_trig = item.head.time_stamp;
                                if double(ecgGroup{end}.head.time_stamp - ptGroup{1}.head.time_stamp)*2.5*10^-3 > param.nSecs
                                    nPTclip = 11*200;
                                    if sysFreeMax; nPTclip = nPTclip*2; end
                                    nECGclip = 11*10;
                                    if ~isfield(param,'startTime')            
                                        ncha = cellfun(@(x) x.head.channels, ptGroup);
                                        ptGroup = ptGroup(ncha == mode(ncha));
                                        param.startTime = ptGroup{1}.head.time_stamp;
                                        test_pt = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup, 'UniformOutput', false)');
                                        test_pt = reshape(typecast(test_pt(:),'single'),[],mode(ncha)-1);
                                        test_pt = test_pt(1:2:end,:) + test_pt(2:2:end,:)*1i;
                                        test_valid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup, 'UniformOutput', false)'));
                                        param.testM = mean(test_pt(test_valid,:));
                                    end
                                    tic
                                    if numel(ptGroup) > nPTclip && numel(ecgGroup) > nECGclip
                                        shiftvector = prompt_run_predict(ptGroup(end-nPTclip+1:end), ecgGroup(end-nECGclip+1:end), net, param, metadata, logging);
                                    else
                                        shiftvector = prompt_run_predict(ptGroup, ecgGroup, net, param, metadata, logging);
                                    end
                                    elapsedTime = toc;
                                    % =========== For Phantom Test Only =========== %
                                    % shiftvector = 10*rand(1,3); param.endExp = 10;
                                    % =========== For Phantom Test Only =========== %
                                    % update param.endExp to accommodate respiratory shift
                                    if shiftvector(3) > param.endExp  && any(predshift(end-19:end,3)>param.endExp)
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
                                % Send shift vector through Feedback
                                if sendRTFB
                                    connection.send_feedback('PTShift', feedbackData);
                                end
                            end     % ~runTraining & ecg triggered
                        end     % if waveform_id is 0 or 16

                    elseif isempty(item)
                        break;

                    else
                        logging.error("Unhandled data type: %s", class(item))
                    end
                end
            catch ME
                logging.error(sprintf('%s\nError in %s (%s) (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ME.stack(1).('line')));
            end % done collecting data

            if ~runTraining && ~exist('info','var')
                load(fullfile(trainlist(end).folder,trainlist(end).name), 'info')
            end

            % ----------------------------------------------------------
            % Image data group
            % ----------------------------------------------------------
            if ~isempty(imgGroup{1})
                logging.info("Processing a group of images (untriggered)")
                if runTraining
                    [image, imdata] = prompt_process_images(imgGroup(1:imgCounter), metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                elseif contains(metadata.measurementInformation.protocolName,'test', 'IgnoreCase', true)
                    [image, imdata]  = prompt_process_images(imgGroup(1:imgCounter), metadata, logging, ref);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                end
                imgGroup = cell(1,0);
            end

            % ----------------------------------------------------------
            % Waveform data group
            % ----------------------------------------------------------
            if ~isempty(ptGroup) && ~isempty(ecgGroup)
                logging.info("Processing a group of PT data (untriggered)")
                if runTraining
                    ptdata = prompt_process_waveform(ptGroup, ecgGroup, metadata, logging);
                elseif exist('param','var')
                    ptdata = prompt_process_waveform(ptGroup, ecgGroup, metadata, logging, param);
                end
                ptGroup = cell(1,0);
                ecgGroup = cell(1,0);
            end

            % ----------------------------------------------------------
            % Train network or calculate prediction error
            % ----------------------------------------------------------
            if runTraining
                if exist('imdata','var') && exist('ptdata','var')
                    image = prompt_train_network(imdata, ptdata, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Processed PT or image shift data not found")
                end
            else
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
                    else
                        save(filename,'predshift', 'predskip');
                        image = prompt_plot_predict([], predshift, param, info, metadata, logging);
                    end
                    logging.debug("Sending image to client");
                    connection.send_image(image);

                    if exist('ptdata','var')
                        save(filename, 'ptdata','-append');
                    end

                else
                    logging.warn("Predicted shift data not found")
                end
            end

            connection.send_close();

            % Reset gpu device
            if gpuDeviceCount
                gpuDevice([]);
            end
            delete(gcp('nocreate'));

            return
        end  % end of process()

    end
end
