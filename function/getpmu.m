classdef getpmu < handle
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
            wavGroup = cell(1,0); % ismrmrd.Waveform;

            try
                while true
                    item = next(connection);

                    % ----------------------------------------------------------
                    % Raw k-space data messages
                    % ----------------------------------------------------------
                    if isa(item, 'ismrmrd.Acquisition')
%                         logging.info("Do nothing to raw data")

                    % ----------------------------------------------------------
                    % Image data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
%                         logging.info("Do nothing to image data")
                            if ~exist('info','var')
                                % Save header info for image generation
                                global info
                                info.head = item.head;
                                info.attribute_string = item.attribute_string;
                            end

                    % ----------------------------------------------------------
                    % Waveform data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Waveform') 
%                         if item.head.waveform_id == 0
                            wavGroup{end+1} = item;
%                         end

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
            % Waveform data group
            % ----------------------------------------------------------
            if ~isempty(wavGroup)
                logging.info("Processing a group of waveform data (untriggered)")
                image = obj.process_waveform(wavGroup, metadata, logging);
                logging.debug("Sending image to client");
                connection.send_image(image);
                logging.info("Processing a group of waveform data (untriggered)")
%                 if ispc
%                     save(['C:\MIDEA\NXVA31A_176478\Data\mat\' metadata.measurementInformation.protocolName '.mat'],'metadata','wavGroup','acqGroup')
%                 elseif isunix
%                     save(['/tmp/share/prompt/PMU_' metadata.measurementInformation.protocolName '.mat'],'metadata','wavGroup','acqGroup')
%                 end
                wavGroup = cell(1,0);
            else
                logging.warn("waveform data was not received.")
            end

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_WAVEFORM
        function image = process_waveform(obj, group, metadata, logging)
            global info
            sysFreeMax = contains(metadata.acquisitionSystemInformation.systemModel,'Free.Max','IgnoreCase',true);
            wavid = cell2mat(cellfun(@(x) x.head.waveform_id, group, 'UniformOutput', false)');

            if any(wavid == 16)
                ptGroup = group(wavid==16);
                ncha = cellfun(@(x) x.head.channels, ptGroup);

                if ~sysFreeMax
                    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)');
                    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)'));
                else
                    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(1:10,1:end-1), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)');
                    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:10,end), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)'));
                end
                ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
                ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
                ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6;
            else
                fprintf('No PT data found')
            end

            % Extract ecg data
            if sysFreeMax
                ecgGroup = group(wavid==3);
                ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,2)==2048, ecgGroup, 'UniformOutput', false)');
            else
                ecgGroup = group(wavid==0);
                ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            end
            ecgdata.data = cell2mat(cellfun(@(x) x.data, ecgGroup, 'UniformOutput', false)');
            ecgdata.nSamples = sum(cell2mat(cellfun(@(x) x.head.number_of_samples, ecgGroup, 'UniformOutput', false)'));
            if any(wavid == 16)
                ecgdata.time =  double(uint32 (1:ecgdata.nSamples) + ecgGroup{1}.head.time_stamp - ptGroup{find(ncha == mode(ncha),1)}.head.time_stamp)'*2.5*10^-3;
            else
                ecgdata.time =  double((ecgGroup{1}.head.time_stamp:ecgGroup{end}.head.time_stamp+uint32(ecgGroup{end}.head.number_of_samples)-1)  - ecgGroup{1}.head.time_stamp)'*2.5*10^-3;
            end
            ecgdata.trigger(ecgdata.time==0) = [];
            ecgdata.time(ecgdata.time==0) = [];
            ecgdata.nSamples = numel(ecgdata.trigger);
            ecgdata.medianRR =  median(diff(ecgdata.time(ecgdata.trigger)));

            % Save figure to output folder
            fig = figure;
            plot(ptdata.rawtime,real(ptdata.rawdata(:,1)))
            xline(ecgdata.time(ecgdata.trigger))
            text(ecgdata.time(ecgdata.trigger),min(real(ptdata.rawdata(:,1)))*ones(sum(ecgdata.trigger),1),string(1:sum(ecgdata.trigger)))
%             plot(ecgdata.time,ecgdata.data(:,1))
%             set(gcf,'Position', [0 0 1200 900])
%             if any(wavid == 16)
%                 title(sprintf('PT data exist, total number %i',sum(wavid==16)))
%             else
%                 title('No PT data found')
%             end

            if ispc
                figname = fullfile(pwd,'output','ECG.png');
            elseif isunix
                figname = fullfile('/tmp/share/prompt','ECG.png');
            end
            saveas(fig, figname)
            close(fig)

            data = uint16(255 - rgb2gray(imread(figname)))';
            image = pack_image(data, info);

        end     % end of process_waveform()

    end
end
