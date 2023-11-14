classdef prompt < handle
    methods
        %% PROCESS
        function process(obj, connection, config, metadata, logging)

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

            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            runTraining = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTcalibrate'))).value); %contains(metadata.measurementInformation.protocolName,'train', 'IgnoreCase', true);
            sendRTFB = logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTFB'))).value);
            gateWindow = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'PTgateWindow'))).value;
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
                            if ~runTraining && sum(item.data(:,5)) && (item.head.time_stamp - last_trig)*2.5*10^-3 > 0.5
                                last_trig = item.head.time_stamp;
                                if double(ecgGroup{end}.head.time_stamp - ptGroup{1}.head.time_stamp)*2.5*10^-3 > param.nSecs
                                    nPTclip = 11*200;
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
                                        shiftvector = obj.run_predict(ptGroup(end-nPTclip+1:end), ecgGroup(end-nECGclip+1:end), net, param, metadata, logging);
                                    else
                                        shiftvector = obj.run_predict(ptGroup, ecgGroup, net, param, metadata, logging);
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
                                    param.gate = [param.endExp-gateWindow, param.endExp+gateWindow];
                                    isSkipAcq = logical(shiftvector(3) > param.gate(2) || shiftvector(3) < param.gate(1));
                                    predshift(end+1,:) = shiftvector;
                                    predskip(end+1,:) = [double(isSkipAcq), param.gate];
                                    %feedbackData = PTshiftFBData(shiftvector, isSkipAcq, logging);
                                    feedbackData = PTshiftFBData([0 0 shiftvector(3)], isSkipAcq, logging);
                                    logging.debug("Predicted shift dX: %.2f, dY: %.2f, dZ: %.2f. Skip: %i. -- Time used: %f.", feedbackData.shiftVec(1), feedbackData.shiftVec(2), feedbackData.shiftVec(3), isSkipAcq, elapsedTime)   
                                else % PT samples not sufficient for prediction
                                    param.gate = [param.endExp-gateWindow, param.endExp+gateWindow];
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
                if exist('imdata')
                    metadata.userParameters.userParameterLong(end+1).name = 'NumberOfMeasurements';
                    metadata.userParameters.userParameterLong(end).value = size(imdata.shiftvec,1);
                end
                imgGroup = cell(1,0);
            end

            % ----------------------------------------------------------
            % Waveform data group
            % ----------------------------------------------------------
            if ~isempty(ptGroup) && ~isempty(ecgGroup)
                logging.info("Processing a group of PT data (untriggered)")
                if runTraining
                    ptdata = obj.process_waveform(ptGroup, ecgGroup, metadata, logging);
                elseif exist('param','var')
                    ptdata = obj.process_waveform_test(ptGroup, ecgGroup, param, metadata, logging);
                end
                ptGroup = cell(1,0);
                ecgGroup = cell(1,0);
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
                        image = obj.plot_predict(imdata.shiftvec, predshift, param, info, metadata, logging);
                    else
                        save(filename,'predshift', 'predskip');
                        image = obj.plot_predict([], predshift, param, info, metadata, logging);
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

            return
        end  % end of process()

        %% PROCESS_IMAGES
        function [image, imdata] = process_images(obj, group, metadata, logging, ref)

            % Calculate image shift
            if nargin < 5
                imdata  = calculateImageShift(group, metadata, logging);
            else
                imdata  = calculateImageShift(group, metadata, logging, ref);
            end

            % Find end expiratory
            if size(imdata.shiftvec,1) > 10
                shiftvec_sort = sort(imdata.shiftvec(6:end,3),'descend');
            else
                shiftvec_sort = sort(imdata.shiftvec(2:end,3),'descend');
            end
            while shiftvec_sort(1) - shiftvec_sort(2) > 0.5
                shiftvec_sort(1) = [];
            end
            imdata.endExp = shiftvec_sort(1);
            logging.info('Training end expiratory: %.2f.', imdata.endExp)

            % Pack cropped reference images
            for ii = 1:size(imdata.ref_crop,3)
                if imdata.isFlip(ii)
                    ima = ismrmrd.Image(transpose(single(imdata.ref_crop(:,:,ii))));
                else
                    ima = ismrmrd.Image(single(imdata.ref_crop(:,:,ii)));
                end

                % Copy original image header, but keep the new data_type
                data_type = ima.head.data_type;
                ima.head = group{ii}.head;
                ima.head.data_type = data_type;
                ima.head.field_of_view = [group{ii}.head.field_of_view(1:2)./3, group{ii}.head.field_of_view(3)];
                ima.head.matrix_size = size(ima.data, [1 2 3]);

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
        function ptdata = process_waveform(obj, ptGroup, ecgGroup, metadata, logging)

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
            time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
            time_mx(time_mx>0) = nan;
            [~, ptdata.param.pk] = max(time_mx, [], 1,'omitnan');

            if any(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements')) && metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements'))).value < numel(ptdata.param.pk)
                ntrigs = find(ecgdata.trigger);
                ecgdata.trigger(ntrigs(find(diff(ecgdata.time(ecgdata.trigger)) < 0.5)+1)) = false;
                trig_time_diff = (ptdata.rawtime - ecgdata.time(ecgdata.trigger).')>0 & (ptdata.rawtime - ecgdata.time(ecgdata.trigger).') < metadata.sequenceParameters.echo_spacing*5*10^-3;
                idx_trigs = find(ecgdata.trigger);
                ecgdata.trigger(idx_trigs(logical(sum(trig_time_diff(~ptdata.isvalid,:))))) = false;

                time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
                time_mx(time_mx>0) = nan;
                [~, ptdata.param.pk] = max(time_mx, [], 1,'omitnan');
            end

            ptdata.ecgdata = ecgdata;

        end     % end of process_waveform()

        %% PROCESS_WAVEFORM_TEST
        function ptdata = process_waveform_test(obj, ptGroup, ecgGroup, param, metadata, logging)

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
            [ptdata.data, ptdata.time, ptdata.param] = processPT(ptdata, logging, param);

            % Find trigger indices
            time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
            time_mx(time_mx>0) = nan;
            [~, ptdata.param.pk] = max(time_mx, [], 1,'omitnan');

            if any(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements')) && metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements'))).value < numel(ptdata.param.pk)
                ntrigs = find(ecgdata.trigger);
                ecgdata.trigger(ntrigs(find(diff(ecgdata.time(ecgdata.trigger)) < 0.5)+1)) = false;
                trig_time_diff = (ptdata.rawtime - ecgdata.time(ecgdata.trigger).')>0 & (ptdata.rawtime - ecgdata.time(ecgdata.trigger).') < metadata.sequenceParameters.echo_spacing*5*10^-3;
                idx_trigs = find(ecgdata.trigger);
                ecgdata.trigger(idx_trigs(logical(sum(trig_time_diff(~ptdata.isvalid,:))))) = false;

                time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
                time_mx(time_mx>0) = nan;
                [~, ptdata.param.pk] = max(time_mx, [], 1,'omitnan');
            end

            ptdata.ecgdata = ecgdata;

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
            figname = fullfile(pwd,'output','Test_PT.png');
            saveas(fig, figname)
            close(fig)

        end     % end of process_waveform_test()

        %% TRAIN_NETWORK
        function image = train_network(obj, imdata, ptdata, info, metadata, logging)

            % Find correlation between ptdata and imdata
            ptdata.param.cor = sign(corr(imdata.shiftvec(:,3),ptdata.data(ptdata.param.pk,:)));
            ptdata.param.cor(isnan(ptdata.param.cor)) = 1;
            ptdata.data = ptdata.data * diag(ptdata.param.cor);

            % Run training
            logging.info("Training network...")
            [net, param] = runTraining(imdata, ptdata, logging);
            param.coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
            [~, idx] = sort(param.coils);
            param.coils = param.coils(idx);

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
            param.figName{end+1} = fullfile(pwd,'output','Train_PT.png');
            saveas(fig, param.figName{end})
            close(fig)
            
            for ii = 1:numel(param.figName)
                data = uint16(255 - rgb2gray(imread(param.figName{ii})))';
                image{ii} = obj.pack_image(data, info);
            end

            % Save training data
            tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
            filename = sprintf("train_%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
            if ispc
                filename = fullfile(pwd,'output',filename);
            elseif isunix
                filename = fullfile('/tmp/share/prompt',filename);
            end
            save(filename,'imdata', 'ptdata','net', 'param', 'info');

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
            ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6 + double(ptGroup{1}.head.time_stamp - param.startTime)*2.5*10^-3;
            % Extract ecg data
            ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            ecgdata.time =  double((ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+uint32(ecgGroup{end}.head.number_of_samples)) - param.startTime)'*2.5*10^-3;
            if numel(ecgdata.time) > numel(ecgdata.trigger)
                ecgdata.time(numel(ecgdata.trigger)+1:end) = [];
            end

            % Process PT
            [ptdata.data, ptdata.time] = processPT(ptdata, logging, param);

            % Find trigger indices
            ntrigs = find(ecgdata.trigger);
            ecgdata.trigger(ntrigs(find(diff(ecgdata.time(ecgdata.trigger)) < 0.5)+1)) = false;
%             trig_time_diff = (ptdata.rawtime - ecgdata.time(ecgdata.trigger).')>0 & (ptdata.rawtime - ecgdata.time(ecgdata.trigger).') < metadata.sequenceParameters.echo_spacing*2*10^-3;
%             idx_trigs = find(ecgdata.trigger);
%             ecgdata.trigger(idx_trigs(logical(sum(trig_time_diff(~ptdata.isvalid,:))))) = false;

            time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
            time_mx(time_mx>0) = nan;
            [~, param.pk] = max(time_mx, [], 1,'omitnan');

            % Pack PT into NN input array
            temp = ptdata.data(param.pk(end)-param.numPT*param.nSecs+1:param.pk(end),:);
            InData = ((temp - mean(temp)) ./ std(temp))';
            shiftvector = predict(net,InData,'MiniBatchSize',1);
            
%             figure(1)
%             plot(ptdata.rawtime,abs(ptdata.rawdata(:,1)))
%             hold on
%             xline(ptdata.time(param.pk))
%             plot(ecgdata.time, ecgdata.trigger*0.1)
%             plot(ptdata.time(param.pk(end)-param.numPT*param.nSecs+1:param.pk(end)),temp(:,1)-mean(temp(:,1)),'*')
%             hold off

        end     % end of run_predict()

        %% TEST_NETWORK
        function image = plot_predict(obj, OtData, yData, param, info, metadata, logging)
            
            % Check matrix size 
            if ~isempty(OtData) && ~any(size(OtData) ~= size(yData))
                OtData(1:sum(isnan(yData(:,1))),:) = nan;
                param.predskip(1:sum(isnan(yData(:,1))),2:3) = nan;
                figName = genPlots(OtData, yData, param);

                for ii = 1:numel(figName)
                    data = uint16(255 - rgb2gray(imread(figName{ii})))';
                    image{ii} = obj.pack_image(data, info);
                end
            else
                ylimit = [min(yData(:))-0.5 max(yData(:))+0.5];
                fig = figure;
                subplot(size(yData,2),1,1); plot(yData(:,1),'k');
                xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
                legend('prediction','Location','northwest'); legend('boxoff')
                subplot(size(yData,2),1,2); plot(yData(:,2),'k');
                xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
                subplot(size(yData,2),1,3); plot(yData(:,3),'k'); 
                if isfield(param,'predskip'); hold on; plot(param.predskip(:,2:3),'k--','LineWidth',3); xline(find(~param.predskip(:,1)),'LineWidth',3); hold off;
                elseif isfield(param,'endExp'); yline(param.endExp,'k-.','end expiration','LineWidth',3); end
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
