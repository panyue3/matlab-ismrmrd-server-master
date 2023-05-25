classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)
            logging.info('Config: \n%s', config);
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

            runTraining = contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true);
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
                        if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                            imgGroup{end+1} = item;
                        end

                    % ----------------------------------------------------------
                    % Waveform data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Waveform') 
                        if item.head.waveform_id == 16 || item.head.waveform_id == 0
                            wavGroup{end+1} = item;
                            if ~ runTraining && item.head.waveform_id == 0 && sum(item.data(:,5))
                                tic
                                shiftvector = obj.run_predict(wavGroup, net, param, metadata, logging);
                                elapsedTime = toc;
                                logging.debug("Predicted shift dX: %.2f, dY: %.2f, dZ: %.2f. -- time used: %f ", shiftvector(1), shiftvector(2), shiftvector(3), elapsedTime)
                                predshift(end+1,:) = shiftvector;

                             % ++++++++++ SEND SHIFTVECTOR TO SEQUENCE ++++++++++ %
                             % ++++++++++ SEND SHIFTVECTOR TO SEQUENCE ++++++++++ %
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

            % Save header info for image generation
            info.head = imgGroup{1}.head;
            info.attribute_string = imgGroup{1}.attribute_string;

            % ----------------------------------------------------------
            % Image data group
            % ----------------------------------------------------------
            if ~isempty(imgGroup)
                logging.info("Processing a group of images (untriggered)")
                if runTraining
                    [image, imdata] = obj.process_images(imgGroup, metadata, logging);
                else
                    [image, imdata]  = obj.process_images(imgGroup, metadata, logging, ref);
                end                           
                logging.debug("Sending image to client");
                connection.send_image(image);
                imgGroup = cell(1,0);
            else
                logging.warn("Image was not received.")
            end

            % ----------------------------------------------------------
            % Waveform data group
            % ----------------------------------------------------------
            if ~isempty(wavGroup)
                if runTraining
                    logging.info("Processing a group of PT data (untriggered)")
                    [image, ptdata] = obj.process_waveform(wavGroup, info, metadata, logging);
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
                if exist('imdata','var') && exist('predshift','var')
                    image = obj.plot_predict(imdata.shiftvec, predshift, info, metadata, logging);
                    logging.debug("Sending image to client");
                    connection.send_image(image);
                else
                    logging.error("Image shift data not found")
                end
            end

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_IMAGES
        function [image, imdata] = process_images(obj, group, metadata, logging, ref)

            % Calculate image shift
            if contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true)
                [imdata.shiftvec, imdata.isoutlier]  = calculateImageShift(group, metadata, logging);
            else
                [imdata.shiftvec, imdata.isoutlier]  = calculateImageShift(group, metadata, logging, ref);
            end

            % Save figure to output folder
            fig = figure;
            hold on
            plot(imdata.shiftvec(:,1),'k:'); plot(imdata.shiftvec(:,2),'k--'); plot(imdata.shiftvec(:,3),'k');
            if ~isempty(find(imdata.isoutlier, 1))
                xline(find(imdata.isoutlier),'LineWidth',2,'Color',[0.7 0.7 0.7]); 
            end
            xlim([0 size(imdata.shiftvec,1)]);
            ylabel('Displacement (mm)'); title('Image Disp');
            legend('dX','dY','dZ','Location','southoutside','NumColumns',3);
            hold off
            if contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true)
                figname = fullfile(pwd,'output','Train_Disp.png');
            else
                figname = fullfile(pwd,'output','Test_Disp.png');
            end
            saveas(fig, figname)
            close(fig)

            data = uint16(255 - rgb2gray(imread(figname)))';
            image = obj.pack_image(data, group{1});

        end     % end of process_images()

        %% PROCESS_WAVEFORM
        function [image, ptdata] = process_waveform(obj, group, info, metadata, logging)

            % Separate waveforms into PT and ECG
            waveID = cellfun(@(x) x.head.waveform_id, group);
            ptGroup  = group(waveID == 16);
            ecgGroup = group(waveID == 0);
            ncha = cellfun(@(x) x.head.channels, ptGroup);
            ptGroup = ptGroup(ncha == mode(ncha));

            % Extract pt data
            ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup, 'UniformOutput', false)');
            ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
            ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
            ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup, 'UniformOutput', false)'));
            ptdata.rawtime = (double(ptGroup{1}.head.time_stamp):0.2:double(ptGroup{end}.head.time_stamp)+1.8)'*2.5*10^-3;
            % Extract ecg data
            ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            ecgdata.time =  double(ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+39)'*2.5*10^-3 - ptdata.rawtime(1);
            ptdata.rawtime = ptdata.rawtime - ptdata.rawtime(1);

            % Process PT
            [ptdata.data, ptdata.time, ptdata.param] = processPT(ptdata, logging);

            % Find trigger indices
            [~, ptdata.param.pk] = min(abs(ptdata.time - ecgdata.time(ecgdata.trigger).'), [], 1);

            % Save figure to output folder
            fig = figure;
            hold on
            plot(ptdata.time, ptdata.data,'k')
            xlim([0 max(ptdata.time)]);
            title('PT');
            hold off
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
            ptdata.param.M = ptdata.param.M .* ptdata.param.cor;

            logging.info("Training network...")
            [net, param] = runTraining(imdata, ptdata, logging);
            param.coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
            [~, idx] = sort(param.coils);
            param.coils = param.coils(idx);
            save(filename,'net', 'param', '-append');

            data = uint16(255 - rgb2gray(imread(param.figName{1})))';
            image{1} = obj.pack_image(data, info);

            data = uint16(255 - rgb2gray(imread(param.figName{2})))';
            image{2} = obj.pack_image(data, info);

        end     % end of train_network()

        %% RUN_PREDICT
        function shiftvector = run_predict(obj, group, net, param, metadata, logging)

            % Separate waveforms into PT and ECG
            waveID = cellfun(@(x) x.head.waveform_id, group);
            ptGroup  = group(waveID == 16);
            ecgGroup = group(waveID == 0);
            ncha = cellfun(@(x) x.head.channels, ptGroup);
            ptGroup = ptGroup(ncha == mode(ncha));

            if double(ecgGroup{end}.head.time_stamp - ptGroup{1}.head.time_stamp)*2.5*10^-3 > param.nSecs
                % Extract pt data
                nPTclip = 10*200;
                if numel(ptGroup) > nPTclip
                    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup(end-nPTclip+1:end), 'UniformOutput', false)');
                    ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
                    ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
                    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup(end-nPTclip+1:end), 'UniformOutput', false)'));
                    ptdata.rawtime = (double(ptGroup{end-nPTclip+1}.head.time_stamp):0.2:double(ptGroup{end}.head.time_stamp)+1.8)'*2.5*10^-3;
                    % Extract ecg data
                    ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
                    ecgdata.time =  double((ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+39)  - ptGroup{1}.head.time_stamp)'*2.5*10^-3;
                    ptdata.rawtime = ptdata.rawtime - double(ptGroup{1}.head.time_stamp)*2.5*10^-3;
                    ecgdata.trigger(ecgdata.time<min(ptdata.rawtime)) = [];
                    ecgdata.time(ecgdata.time<min(ptdata.rawtime)) = [];
                else
                    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup, 'UniformOutput', false)');
                    ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
                    ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
                    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup, 'UniformOutput', false)'));
                    ptdata.rawtime = (double(ptGroup{1}.head.time_stamp):0.2:double(ptGroup{end}.head.time_stamp)+1.8)'*2.5*10^-3;
                    % Extract ecg data
                    ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
                    ecgdata.time =  double(ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+39)'*2.5*10^-3 - ptdata.rawtime(1);
                    ptdata.rawtime = ptdata.rawtime - ptdata.rawtime(1);
                end
    
                % Process PT
                [ptdata.data, ptdata.time] = processPT(ptdata, logging, param);
    
                % Find trigger indices
                [~, param.pk] = min(abs(ptdata.time - ecgdata.time(ecgdata.trigger).'), [], 1);

                % Pack PT into NN input array
                InData = ptdata.data(param.pk(end)-param.numPT*param.nSecs+1:param.pk(end),:)';
                shiftvector = predict(net,InData,'MiniBatchSize',1);
            else
                shiftvector = nan(1,3);
            end

        end     % end of run_predict()

        %% TEST_NETWORK
        function image = plot_predict(obj, OtData, yData, info, metadata, logging)
            
            % Check matrix size 
            if any(size(OtData) ~= size(yData))
                logging.error('Ground truth and prediction matrices size do not match')
            end

            nBeats = sum(isnan(yData(:,1)));
            eData = OtData - yData;
            err = 10 * log10(sum(eData.^2,'all','omitnan') / sum(OtData(nBeats+1:end,:).^2,'all'));

            ylimit = [min([OtData(:); yData(:); eData(:)]) max([OtData(:); yData(:); eData(:)])];
            fig = figure;
            subplot(size(OtData,2),1,1); plot(OtData(:,1),'k'); hold on; plot(yData(:,1),'k--'); plot(eData(:,1),'k:');
            xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
            legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
            subplot(size(OtData,2),1,2); plot(OtData(:,2),'k'); hold on; plot(yData(:,2),'k--'); plot(eData(:,2),'k:');
            xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
            subplot(size(OtData,2),1,3); plot(OtData(:,3),'k'); hold on; plot(yData(:,3),'k--'); plot(eData(:,3),'k:');
            xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
            sgtitle(sprintf('Test Err: %.2f', err))
            hold off
            set(gcf,'Position', [0 0 1200 900])
            figName = fullfile(pwd,'output','Test_Result.png');
            saveas(fig, figName)
            close(fig)
            data = uint16(255 - rgb2gray(imread(figName)))';
            image{1} = obj.pack_image(data, info);

            fig = figure;
            hold on
            scatter(yData(:,1),OtData(:,1),'k+');
            scatter(yData(:,2),OtData(:,2),'kx');
            scatter(yData(:,3),OtData(:,3),'ko');
            xlabel("Predicted Shift")
            ylabel("Actual Shift")
            m = min(OtData,[],'all');
            M=max(OtData,[],'all');
            xlim([m M])
            ylim([m M])
            plot([m M], [m M], "r--")
            legend('dX','dY','dZ','','Location','Best')
            figName = fullfile(pwd,'output','Test_Predit.vs.Actual.png');
            saveas(fig, figName)
            close(fig)
            data = uint16(255 - rgb2gray(imread(figName)))';
            image{2} = obj.pack_image(data, info);
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
