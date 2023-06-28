classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)
            logging.info('Config: \n%s', config);
            if ~any(strcmp({metadata.userParameters.userParameterLong.name}, 'PilotTone')) || ~metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PilotTone'))).value
                logging.error("Pilot Tone was not turned on.")
            end

            if isempty(gcp('nocreate'))
                parpool
            end

            % Check if output folders exist
            if ~exist('output', 'dir')
                mkdir('output')
            end
            if isunix && ~exist('/tmp/share/prompt', 'dir')
                mkdir('/tmp/share/prompt')
            end

            runTraining = metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTcalibrate'))).value; %contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true);
            sendRTFB = metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTShift'))).value;
            if ~runTraining
                predshift = [];

                % Load training result. If multiple training was done, read in the last file generated
                tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
                filename = sprintf("%s.*.mat", tmp{11});
                if ispc
                    trainlist = dir(fullfile(pwd,'output',filename));
                elseif isunix
                    trainlist = dir(fullfile('/tmp/share/prompt',filename));
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
                    ref = load(fullfile(trainlist(end).folder,trainlist(end).name), 'refIma','isFlip');

                    % Check if coils match training series
                    coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
                    [~, idx] = sort(coils);
                    coils = coils(idx);
                    if ~matches(cell2str(coils),cell2str(param.coils),"IgnoreCase",true)
                        logging.error("Receiver coils turned on do not match the training series.")
                    end
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
            imgGroup = cell(1,0); % ismrmrd.Image;
            ptGroup = cell(1,0); % ismrmrd.Waveform;
            ecgGroup = cell(1,0); % ismrmrd.Waveform;
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
                            if ~sendRTFB
                                imgGroup{end+1} = item;
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
                        elseif item.head.waveform_id == 0
                            ecgGroup{end+1} = item;                            
                            if ~ runTraining && sum(item.data(:,5))
                                if double(ecgGroup{end}.head.time_stamp - ptGroup{1}.head.time_stamp)*2.5*10^-3 > param.nSecs
                                    nPTclip = 11*200;
                                    nECGclip = 11*10;
                                    param.startTime = ptGroup{1}.head.time_stamp;   
                                    tic
                                    if numel(ptGroup) > nPTclip && numel(ecgGroup) > nECGclip
                                        shiftvector = obj.run_predict(ptGroup(end-nPTclip+1:end), ecgGroup(end-nECGclip+1:end), net, param, metadata, logging);
                                    else
                                        shiftvector = obj.run_predict(ptGroup, ecgGroup, net, param, metadata, logging);
                                    end
                                    elapsedTime = toc;
                                    predshift(end+1,:) = shiftvector;
                                    feedbackData = PTshiftFBData(shiftvector, logging);
                                    logging.debug("Predicted shift dX: %.2f, dY: %.2f, dZ: %.2f -- Time used: %f.", feedbackData.shiftVec(1), feedbackData.shiftVec(2), feedbackData.shiftVec(3), elapsedTime)

                                    % Send shift vector through Feedback
                                    if sendRTFB && ~any(isnan(shiftvector))
                                        connection.send_feedback('PTShift', feedbackData);
                                    end
                                else
                                    predshift(end+1,:) = nan(1,3);
                                end
                            end
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

            % ----------------------------------------------------------
            % Image data group
            % ----------------------------------------------------------
            if ~isempty(imgGroup)
                logging.info("Processing a group of images (untriggered)")           
                if runTraining
                    [image, imdata] = obj.process_images(imgGroup, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                elseif contains(metadata.measurementInformation.protocolName,'test', 'IgnoreCase', true)
                    [image, imdata]  = obj.process_images(imgGroup, metadata, logging, ref);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                end

                imgGroup = cell(1,0);
            else
                logging.warn("Image was not received.")
            end

            % ----------------------------------------------------------
            % Waveform data group
            % ----------------------------------------------------------
            if ~isempty(ptGroup) && ~isempty(ecgGroup)
                if runTraining
                    logging.info("Processing a group of PT data (untriggered)")
                    [image, ptdata] = obj.process_waveform(ptGroup, ecgGroup, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                end
                wavGroup = cell(1,0);
            else
                logging.warn("PT data was not received.")
            end

            % ----------------------------------------------------------
            % Train network or calculate prediction error
            % ----------------------------------------------------------
            if runTraining
                if exist('imdata','var') && exist('ptdata','var')
                    image = obj.train_network(imdata, ptdata, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Processed PT or image shift data not found")
                end
            else
                if exist('predshift','var')
                    if ~sendRTFB && exist('imdata','var')
                        image = obj.plot_predict(imdata.shiftvec, predshift, info, metadata, logging);
                    else
                        image = obj.plot_predict([], predshift, info, metadata, logging);
                    end
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Predicted shift data not found")
                end
            end

            connection.send_close();
            % Reset gpu device
            if gpuDeviceCount
                gpuDevice([]);
            end

            return
        end  % end of process()

        %% PROCESS_IMAGES
        function [image, imdata] = process_images(obj, group, metadata, logging, ref)

            % Calculate image shift
            if nargin < 5
                [imdata.shiftvec, ref_crop]  = calculateImageShift(group, metadata, logging);
            else
                [imdata.shiftvec, ref_crop]  = calculateImageShift(group, metadata, logging, ref);
            end

            % Pack cropped reference images
            for ii = 1:size(ref_crop,3)
                ima = ismrmrd.Image(single(ref_crop(:,:,ii)));

                % Copy original image header, but keep the new data_type
                data_type = ima.head.data_type;
                ima.head = group{ii}.head;
                ima.head.data_type = data_type;
                ima.head.field_of_view = [group{ii}.head.field_of_view(1:2)./3, group{ii}.head.field_of_view(3)];
                ima.head.matrix_size = size(ref_crop(:,:,ii), [1 2 3]);

                % Add to ImageProcessingHistory
                meta = ismrmrd.Meta.deserialize(group{ii}.attribute_string);
                meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'PROMPT');
                ima = ima.set_attribute_string(ismrmrd.Meta.serialize(meta));
                image{ii} = ima;
            end

            % Save figure to output folder
            fig = figure;
            hold on
            plot(imdata.shiftvec(:,1),'k:'); plot(imdata.shiftvec(:,2),'k--'); plot(imdata.shiftvec(:,3),'k');
            xlim([0 size(imdata.shiftvec,1)]);
            ylabel('Displacement (mm)'); title('Image Disp');
            legend('dX','dY','dZ','Location','southoutside','NumColumns',3);
            hold off
            if nargin < 5
                figname = fullfile(pwd,'output','Train_Disp.png');
            else
                figname = fullfile(pwd,'output','Test_Disp.png');
            end
            saveas(fig, figname)
            close(fig)

            data = uint16(255 - rgb2gray(imread(figname)))';
            image{end+1} = obj.pack_image(data, group{1});

        end     % end of process_images()

        %% PROCESS_WAVEFORM
        function [image, ptdata] = process_waveform(obj, ptGroup, ecgGroup, info, metadata, logging)

            % Check all pt samples have same number of channels
            ncha = cellfun(@(x) x.head.channels, ptGroup);
            ptGroup = ptGroup(ncha == mode(ncha));

            % Extract pt data
            ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup, 'UniformOutput', false)');
            ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
            ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
            ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup, 'UniformOutput', false)'));
            ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6;
            % Extract ecg data
            ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            ecgdata.time =  double((ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+uint32(ecgGroup{end}.head.number_of_samples)) - ptGroup{1}.head.time_stamp)'*2.5*10^-3;

            % Process PT
            [ptdata.data, ptdata.time, ptdata.param] = processPT(ptdata, logging);

            % Find trigger indices
            [~, ptdata.param.pk] = min(abs(ptdata.time - ecgdata.time(ecgdata.trigger).'), [], 1);

            % Save figure to output folder
            fig = figure;
            for i=1:min([ptdata.param.numVCha 4])
                nexttile; hold on;
                plot(ptdata.time, ptdata.data(:,i)-mean(ptdata.data(:,i)),'k')
                plot(ptdata.time, ptdata.data(:,i+ptdata.param.numVCha)-mean(ptdata.data(:,i+ptdata.param.numVCha)),'k--')
                title(sprintf('PT channel %i',i)); xlim([0 max(ptdata.time)]); hold off
            end
            lgd = legend('Real','Imag'); lgd.Layout.Tile = 'south'; lgd.NumColumns = 2;
            set(gcf,'Position', [0 0 1200 900])
            figname = fullfile(pwd,'output','Train_PT.png');
            saveas(fig, figname)
            close(fig)

            data = uint16(255 - rgb2gray(imread(figname)))';
            image = obj.pack_image(data, info);

        end     % end of process_waveform()

        %% TRAIN_NETWORK
        function image = train_network(obj, imdata, ptdata, info, metadata, logging)

            tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
            filename = sprintf("%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
            if ispc
                filename = fullfile(pwd,'output',filename);
            elseif isunix
                filename = fullfile('/tmp/share/prompt',filename);
            end
            save(filename,'imdata', 'ptdata', '-append');

            % Run training
            ptdata.param.cor = sign(corr(imdata.shiftvec(:,3),ptdata.data(ptdata.param.pk,:)));
            ptdata.data = ptdata.data * diag(ptdata.param.cor);

            logging.info("Training network...")
            [net, param] = runTraining(imdata, ptdata, logging);
            param.coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
            [~, idx] = sort(param.coils);
            param.coils = param.coils(idx);
            save(filename,'net', 'param', '-append');

            for ii = 1:numel(param.figName)
                data = uint16(255 - rgb2gray(imread(param.figName{ii})))';
                image{ii} = obj.pack_image(data, info);
            end

        end     % end of train_network()

        %% RUN_PREDICT
        function shiftvector = run_predict(obj, ptGroup, ecgGroup, net, param, metadata, logging)

            % Check all pt samples have same number of channels
            ncha = cellfun(@(x) x.head.channels, ptGroup);
            ptGroup = ptGroup(ncha == mode(ncha));
            
            % Extract pt data
            ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup, 'UniformOutput', false)');
            ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
            ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
            ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup, 'UniformOutput', false)'));
            ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6;
            % Extract ecg data
            ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            ecgdata.time =  double((ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+uint32(ecgGroup{end}.head.number_of_samples)) - param.startTime)'*2.5*10^-3;

            % Process PT
            [ptdata.data, ptdata.time] = processPT(ptdata, logging, param);

            % Find trigger indices
            [~, param.pk] = min(abs(ptdata.time - ecgdata.time(ecgdata.trigger).'), [], 1);

            % Pack PT into NN input array
            InData = ptdata.data(param.pk(end)-param.numPT*param.nSecs+1:param.pk(end),:)';
            InData = (InData - mean(InData,2)) ./ std(InData,[],2);
            shiftvector = predict(net,InData,'MiniBatchSize',1);

        end     % end of run_predict()

        %% TEST_NETWORK
        function image = plot_predict(obj, OtData, yData, info, metadata, logging)
            
            % Check matrix size 
            if ~isempty(OtData)
                if any(size(OtData) ~= size(yData))
                    logging.error('Ground truth and prediction matrices size do not match')
                end
    
                OtData(1:sum(isnan(yData(:,1))),:) = nan;
                figName = genPlots(OtData, yData);

                for ii = 1:numel(figName)
                    data = uint16(255 - rgb2gray(imread(figName{ii})))';
                    image{ii} = obj.pack_image(data, info);
                end
            else
                ylimit = [min(yData(:)) max(yData(:))];
                fig = figure;
                subplot(size(yData,2),1,1); plot(yData(:,1),'k');
                xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
                legend('prediction','Location','northwest'); legend('boxoff')
                subplot(size(yData,2),1,2); plot(yData(:,2),'k');
                xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
                subplot(size(yData,2),1,3); plot(yData(:,3),'k');
                xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
                sgtitle('Predited Shift')
                hold off
                set(gcf,'Position', [0 0 1200 900])
                figName = fullfile(pwd,'output','Predicted_Shift.png');
                saveas(fig, figName)
                close(fig)
                data = uint16(255 - rgb2gray(imread(figName)))';
                image = obj.pack_image(data, info);
            end

        end     % end of plot_predict()

        %% PACK_IMAGE
        function image = pack_image(obj, data, info)

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            image = ismrmrd.Image(data);

            % Copy original image header, but keep the new data_type
            data_type = image.head.data_type;
            image.head = info.head;
            image.head.data_type = data_type;
            image.head.matrix_size = size(data, [1 2 3]);

            % Add to ImageProcessingHistory
            meta = ismrmrd.Meta.deserialize(info.attribute_string);
            meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'PROMPT');
            meta = ismrmrd.Meta.appendValue(meta, 'WindowCenter', 40);
            meta = ismrmrd.Meta.appendValue(meta, 'WindowWidth', 80);
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

        end % end of pack_image

    end
end
