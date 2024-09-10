classdef FIRE_KW_Filter < handle
    % Linting warning suppression:
    %#ok<*INUSD>  Input argument '' might be unused.  If this is OK, consider replacing it by ~
    %#ok<*NASGU>  The value assigned to variable '' might be unused.
    %#ok<*INUSL>  Input argument '' might be unused, although a later one is used.  Ronsider replacing it by ~
    %#ok<*AGROW>  The variable '' appear to change in size on every loop  iteration. Consider preallocating for speed.

    methods
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
            imgGroup = cell(1,0); % ismrmrd.Image;
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
                        if item.head.flagIsSet(item.head.FLAGS.ACQ_LAST_IN_SLICE)
                            logging.info("Processing a group of k-space data")
                            image = obj.process_raw(acqGroup, config, metadata, logging);
                            logging.debug("Sending image to client")
                            connection.send_image(image);
                            acqGroup = {};
                        end

                    % ----------------------------------------------------------
                    % Image data messages
                    % ----------------------------------------------------------
                    elseif isa(item, 'ismrmrd.Image')
                        % Only process magnitude images -- send phase images back without modification
                        if (item.head.image_type == item.head.IMAGE_TYPE.MAGNITUDE)
                            imgGroup{end+1} = item;
                        else
                            connection.send_image(item);
                            continue
                        end

                        % When this criteria is met, run process_group() on the accumulated
                        % data, which returns images that are sent back to the client.
                        % TODO: logic for grouping images
                        if false
                            logging.info("Processing a group of images")
                            image = obj.process_images(imgGroup, config, metadata, logging);
                            logging.debug("Sending image to client")
                            disp('Send image here p1 ...')
                            connection.send_image(image);
                            imgGroup = cell(1,0);
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

            % Process any remaining groups of raw or image data.  This can 
            % happen if the trigger condition for these groups are not met.
            % This is also a fallback for handling image data, as the last
            % image in a series is typically not separately flagged.
            if ~isempty(acqGroup)
                logging.info("Processing a group of k-space data (untriggered)")
                image = obj.process_raw(acqGroup, config, metadata, logging);
                logging.debug("Sending image to client")
                connection.send_image(image);
                acqGroup = cell(1,0);
            end

            if ~isempty(imgGroup)
                logging.info("Processing a group of images (untriggered)")
                image = obj.process_images(imgGroup, config, metadata, logging);
                logging.debug("Sending image to client")
                disp('Send image here p2 ...')
                for i=1:length(image)
                    v_re(i, :) = image{i}.head.position;
                end
                %disp('Slice Position:')
                %disp(v_re)
                connection.send_image(image);
                imgGroup = cell(1,0);
            end

            connection.send_close();
            return
        end

        function image = process_raw(obj, group, config, metadata, logging)
            % This function assumes that the set of raw data belongs to a 
            % single image.  If there's >1 phases, echos, sets, etc., then
            % either the call to this function from process() needs to be
            % adjusted or this code must be modified.

            % Format data into a single [RO PE cha] array
            ksp = cell2mat(permute(cellfun(@(x) x.data, group, 'UniformOutput', false), [1 3 2]));
            ksp = permute(ksp, [1 3 2]);

            % Fourier Transform
            img = fftshift(fft2(ifftshift(ksp)));

            % Sum of squares coil combination
            img = sqrt(sum(abs(img).^2,3));

            % Remove phase oversampling
            img = img(round(size(img,1)/4+1):round(size(img,1)*3/4),:);
            logging.debug("Image data is size %d x %d after coil combine and phase oversampling removal", size(img))
        
            % Normalize and convert to short (int16)
            img = img .* (32767./max(img(:)));
            img = uint16(round(img));

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            image = ismrmrd.Image(img);

            % Find the center k-space index
            kspace_encode_step_1 = cellfun(@(x) x.head.idx.kspace_encode_step_1, group);
            centerLin            = cellfun(@(x) x.head.idx.user(6),              group);
            centerIdx = find(kspace_encode_step_1 == centerLin, 1);

            % Copy the relevant AcquisitionHeader fields to ImageHeader
            image.head = image.head.fromAcqHead(group{centerIdx}.head);

            % field_of_view is mandatory
            image.head.field_of_view  = single([metadata.encoding(1).reconSpace.fieldOfView_mm.x ...
                                                metadata.encoding(1).reconSpace.fieldOfView_mm.y ...
                                                metadata.encoding(1).reconSpace.fieldOfView_mm.z]);

            % Set ISMRMRD Meta Attributes
            meta = struct;
            meta.DataRole               = 'Image';
            meta.ImageProcessingHistory = 'MATLAB';
            meta.WindowCenter           = uint16(16384);
            meta.WindowWidth            = uint16(32768);
            meta.ImageRowDir            = group{centerIdx}.head.read_dir;
            meta.ImageColumnDir         = group{centerIdx}.head.phase_dir;

            % set_attribute_string also updates attribute_string_len
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));
            
            % Call process_image to do actual image inversion
            image = obj.process_images({image});
        end

        function images = process_images(obj, group, config, metadata, logging)
            % Extract image data
            cData = cellfun(@(x) x.data, group, 'UniformOutput', false);
            data = cat(3, cData{:});
            s_a = size(data);
            % Sorting Images
            disp('Sorting Images ...')
            for i=1:size(data,3)
                v_0(i, :) = group{i}.head.position;
            end
            v_1 = v_0(1, :) - v_0(2, :);
            b(1) = 0;
            for i = 2:size(v_0, 1)
                v_2 = v_0(1,:) - v_0(i, :);
                b(i) = sum(v_1.*v_2);
            end
            [I, J] = sort(b);
            disp('New Order:')
            disp(J)
            data = data(:,:,J);
            data_0 = data;
            
            disp('data size = ')
            disp(size(data))
            disp('Filtering Images, I run ...')
            % Normalize and convert to short (int16)
            %data = data .* (32767./max(data(:)));
            %data = int16(round(data));
            % Determine the optimal parameter
            if max(s_a) > 256 % 
                option.Win_L = 32;
                option.step_x = 2;
                option.step_y = 2;
                a_0(:,:,:,1) = data(1:2:end, 1:2:end,:);
                a_0(:,:,:,2) = data(1:2:end, 2:2:end,:);
                a_0(:,:,:,3) = data(2:2:end, 1:2:end,:);
                a_0(:,:,:,4) = data(2:2:end, 2:2:end,:);
                %data = [];
                %data = a_0;
                s_a = size(a_0);
                Is_Interp = 1;
            else
                option.Win_L = 32;
                option.step_x = 2;
                option.step_y = 2;
                Is_Interp = 0;
                a_0 = data;
            end
            %a_f = zeros(s_a);
%             if (s_a(3) > 20) && (s_a(3) < 37)
%                 disp('Separate odd/even ...')
%                 a_f(:,:,1:2:end) = KW_Patch_Filter_Adam(double(data(:,:,1:2:end)), option);
%                 a_f(:,:,2:2:end) = KW_Patch_Filter_Adam(double(data(:,:,2:2:end)), option);
%             else
                disp('Lump together ...')
                delete(gcp('nocreate'));  % Delete the current parallel pool
                parpool(20);         % Create a new parallel pool with 'newSize' workers
                % a_f = KW_Patch_Filter_Adam(double(data), option);
                % a_f = single(KW_Patch_Filter_Adam_Slide(double(data), option));
                a_f = (KW_Patch_Filter_Adam_Slide_Neigh(a_0, option));
%             end
            % Invert image contrast
            %data = int16(abs(32767-data));
                        
            if Is_Interp
                disp('Restore Order with Interp...')
                %data = zeros(2*s_a(1), 2*s_a(2), s_a(3));
                data(1:2:end, 1:2:end,J) = uint16(a_f(:,:,:,1));
                data(1:2:end, 2:2:end,J) = uint16(a_f(:,:,:,2));
                data(2:2:end, 1:2:end,J) = uint16(a_f(:,:,:,3));
                data(2:2:end, 2:2:end,J) = uint16(a_f(:,:,:,4));
            else
                disp('Restore Order without Interp...')
                data(:,:,J) = uint16(a_f);
            end
            
            % Re-slice back into 2D MRD images
            images = cell(1, size(data,3));
            for iImg = 1:size(data,3)
                % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
                image = ismrmrd.Image(data(:,:,iImg));

                % Copy original image header, but keep the new data_type and channels
                newHead = image.head;
                image.head = group{iImg}.head;
                image.head.data_type = newHead.data_type;
                image.head.channels  = newHead.channels;
                %disp(['image.head.ProtocolName = ', image.head.ProtocolName])
                group_image = group{iImg};
                % save(['Group_image_', datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF'), '.mat'], 'group_image')
                % Add to ImageProcessingHistory
                meta = ismrmrd.Meta.deserialize(group{iImg}.attribute_string);
                meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'KW Patch Filter');
                temp_SequenceDescription = meta.SequenceDescription;
                meta.SequenceDescription = [temp_SequenceDescription, '_Filtered'];
                % pause,
                %meta.SequenceDescription = [temp_SequenceDescription(1:end-4), '_Filtered', temp_SequenceDescription(end-3:end)]; % Ding 20231128
                image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));
                %save(['Meta_Data_', datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF'), '.mat'], 'meta')
                images{iImg} = image;
            end
            for i=1:size(data,3)
                v_re(i, :) = images{i}.head.position;
            end
            
            disp('Save data with slice poition ...')
            save(['Temp_Data_0', datestr(now, 'yyyy_mm_dd_HH_MM_SS'), '.mat'], 'data_0', 'a_f', 'v_0', 'v_re', 'b', 'J', 'images', 'metadata', 'option')
            
        end
    end
end
