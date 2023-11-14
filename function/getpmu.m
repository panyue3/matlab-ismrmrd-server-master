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
            acqGroup = cell(1,0); % ismrmrd.Acquisition;
            wavGroup = cell(1,0); % ismrmrd.Waveform;

            try
                while true
                    item = next(connection);

                    % ----------------------------------------------------------
                    % Raw k-space data messages
                    % ----------------------------------------------------------
                    if isa(item, 'ismrmrd.Acquisition')
                        acqGroup{end+1} = item;

                    % ----------------------------------------------------------
                    % Image data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
%                         logging.info("Do nothing to image data")

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
%                 logging.debug("Sending image to client");
%                 connection.send_image(image);
                logging.info("Processing a group of waveform data (untriggered)")
                save(['C:\MIDEA\NXVA31A_176478\Data\mat\' metadata.measurementInformation.protocolName '.mat'],'metadata','wavGroup','acqGroup')
                acqGroup = cell(1,0);
                wavGroup = cell(1,0);
            else
                logging.warn("waveform data was not received.")
            end

            connection.send_close();
            return
        end  % end of process()

        %% PROCESS_WAVEFORM
        function image = process_waveform(obj, group, metadata, logging)

            % Extract ecg data
            wavid = cell2mat(cellfun(@(x) x.head.waveform_id, group, 'UniformOutput', false)');
            ecgGroup = group(wavid==0);
            ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
            ecgdata.data = cell2mat(cellfun(@(x) x.data, ecgGroup, 'UniformOutput', false)');
            ecgdata.time =  double((group{1}.head.time_stamp:group{end}.head.time_stamp+uint32(group{end}.head.number_of_samples))  - group{1}.head.time_stamp)'*2.5*10^-3;
            [~, pk] = findpeaks(double(ecgdata.trigger));
            ecgdata.trigtime = ecgdata.time(pk);

            % Save figure to output folder
            fig = figure;
            plot(diff(ecgdata.trigtime)*1000,'o')
            xlim([0 numel(pk)]);
            set(gcf,'Position', [0 0 1200 900])
            ylim([0 1500])
            figname = fullfile(pwd,'output','ECG.png');
            saveas(fig, figname)
            close(fig)

            data = uint16(255 - rgb2gray(imread(figname)))';
            image = obj.pack_image(data, info);

        end     % end of process_waveform()

    end
end
