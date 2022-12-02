classdef Dataset

    properties
        fid          = -1;
        filename     = '';
        grouppath    = '';
        datapath     = '';
        waveformpath = '';
        xmlpath      = '';
        htypes       = [];
    end

    methods
        function obj = Dataset(filename,groupname)

            % Set the hdf types
            obj.htypes = ismrmrd.util.hdf5_datatypes;

            % If the file exists, open it for read/write
            % otherwise, create it
            if exist(filename,'file')
                obj.fid = H5F.open(filename,'H5F_ACC_RDWR','H5P_DEFAULT');
            else
                fcpl = H5P.create('H5P_FILE_CREATE');
                obj.fid = H5F.create(filename,'H5F_ACC_TRUNC',fcpl,'H5P_DEFAULT');
                H5P.close(fcpl);
            end

            % Set the filename
            obj.filename = filename;

            % Set the group name
            %   default is dataset
            if nargin == 1
                groupname = 'dataset';
            end
            % Set the paths
            obj.grouppath = ['/' groupname];
            obj.xmlpath   = ['/' groupname '/xml'];
            obj.datapath  = ['/' groupname '/data'];
            obj.waveformpath= ['/' groupname '/waveforms'];

            % Check if the group exists
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid,obj.grouppath,lapl_id) == 0)
                % group does not exist, create it
                group_id = H5G.create(obj.fid, obj.grouppath, 0);
                H5G.close(group_id);
            end
            H5P.close(lapl_id);

        end

        function obj = close(obj)
            % close the file
            H5F.close(obj.fid);
        end

        function xmlstring = readxml(obj)
            % Check if the XML header exists
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid,obj.xmlpath,lapl_id) == 0)
                error('No XML header found.');
            end
            H5P.close(lapl_id);

            % Open
            xml_id = H5D.open(obj.fid, obj.xmlpath);

            % Get the type
            xml_dtype = H5D.get_type(xml_id);

            % Read the data
            hdr = H5D.read(xml_id, xml_dtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

            % Output depends on whether or not the stored string was variale length
            if (H5T.is_variable_str(xml_dtype))
                xmlstring = hdr{1};
            else
                xmlstring = hdr';
            end

            % Close the XML
            H5T.close(xml_dtype);
            H5D.close (xml_id);
        end

        function writetext(obj, txt, targetPath)
            txt = char(txt);

            % Delete existing data at target path
            lapl_id = H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, targetPath, lapl_id) == 1)
                H5L.delete(obj.fid, targetPath, 'H5P_DEFAULT');
            end
            H5P.close(lapl_id);

            % Set variable length string type
            dtype = H5T.copy('H5T_C_S1');
            H5T.set_size(dtype, 'H5T_VARIABLE');
            space_id = H5S.create_simple (1, 1, []);
            id = H5D.create(obj.fid, targetPath, dtype, space_id, 'H5P_DEFAULT');
            H5S.close(space_id);

            % Write the data
            H5D.write(id, dtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', {txt});

            % Close the XML
            H5D.close(id);
        end

        function writexml(obj, xmlstring)
            writetext(obj, xmlstring, obj.xmlpath);
        end

        function nacq = getNumberOfAcquisitions(obj)

            % Check if the Data exists
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.datapath, lapl_id) == 0)
                error([obj.datapath ' does not exist in the HDF5 dataset.']);
            end
            dset = H5D.open(obj.fid, obj.datapath);
            space = H5D.get_space(dset);
            H5S.get_simple_extent_dims(space);
            [~,dims,~] = H5S.get_simple_extent_dims(space);
            nacq = dims(1);
            H5S.close(space);
            H5D.close(dset);

        end

        function block = readAcquisition(obj, start, stop)
            if nargin == 1
                % Read all the acquisitions
                start = 1;
                stop = -1;
            elseif nargin == 2
                % Read a single acquisition
                stop = start;
            end

            % Check if the Data exists
            lapl=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.datapath, lapl) == 0)
                error([obj.datapath ' does not exist in the HDF5 dataset.']);
            end

            % Open the data
            dset = H5D.open(obj.fid, obj.datapath);

            % Open the data space
            space = H5D.get_space(dset);

            % Get the size
            [~,dims,~] = H5S.get_simple_extent_dims(space);
            nacq = dims(1);

            % Create a mem_space for reading
            if (stop >= start)
                offset = [start-1];
                dims = [stop-start+1];
                mem_space = H5S.create_simple(1,dims,[]);
            else
                offset = [0];
                dims = [nacq];
                mem_space = H5S.create_simple(1,dims,[]);
            end

            % Read the desired acquisitions
            H5S.select_hyperslab(space,'H5S_SELECT_SET',offset,[1],[1],dims);
            d = H5D.read(dset, obj.htypes.T_Acquisition, ...
                         mem_space, space, 'H5P_DEFAULT');

            % Pack'em
            head = ismrmrd.Dataset.SplitHDF5Header(d.head, ismrmrd.AcquisitionHeader);
            block = cell(1, numel(head));
            for i = 1:numel(block)
                block{i} = ismrmrd.Acquisition(head{i}, d.traj{i}, d.data{i});
            end

            % Clean up
            H5S.close(mem_space);
            H5S.close(space);
            H5D.close(dset);
        end

        function appendAcquisition(obj, acq)
            % Append an acquisition

            % TODO: Check the type of the input

            % The number of acquisitions that we are going to append
            if ~iscell(acq)
                acq = {acq};
            end
            N = numel(acq);

            % Check if the Data exists
            %   if it does not exist, create it
            %   if it does exist increase it's size
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.datapath, lapl_id) == 0)
                % Data does not exist
                %   create with rank 1, unlimited, and set the chunk size
                dims    = [N];
                maxdims = [H5ML.get_constant_value('H5S_UNLIMITED')];
                file_space_id = H5S.create_simple(1, dims, maxdims);

                dcpl = H5P.create('H5P_DATASET_CREATE');
                chunk = [1];
                H5P.set_chunk (dcpl, chunk);
                data_id = H5D.create(obj.fid, obj.datapath, ...
                                     obj.htypes.T_Acquisition, ...
                                     file_space_id, dcpl);
                H5P.close(dcpl);
                H5S.close(file_space_id);

            else
                % Open the data
                data_id = H5D.open(obj.fid, obj.datapath);

                % Open the data space
                file_space_id = H5D.get_space(data_id);

                % Get the size, increment by N
                H5S.get_simple_extent_dims(file_space_id);
                [~,dims,~] = H5S.get_simple_extent_dims(file_space_id);
                dims = [dims(1)+N];
                H5D.set_extent (data_id, dims);
                H5S.close(file_space_id);

            end
            H5P.close(lapl_id);

            % Get the file space
            file_space_id = H5D.get_space(data_id);
            [~,dims,~] = H5S.get_simple_extent_dims(file_space_id);

            % Select the last N block
            offset = [dims(1)-N];
            H5S.select_hyperslab(file_space_id,'H5S_SELECT_SET',offset,[1],[1],[N]);

            % Mem space
            mem_space_id = H5S.create_simple(1,[N],[]);

            % Check and fix the acquisition header types
            % acq.head.check();
            % TODO: Error checking on the sizes of the data and trajectories.

            % Pack the acquisition into the correct struct for writing
            d = struct();
            d.head = ismrmrd.Dataset.CombineHDF5Header(cellfun(@(x) x.head, acq, 'UniformOutput', false));
            d.traj = cellfun(@(x) x.traj,            acq, 'UniformOutput', false);
            d.data = cellfun(@(x) x.serializeData(), acq, 'UniformOutput', false);

            % Write
            H5D.write(data_id, obj.htypes.T_Acquisition, ...
                      mem_space_id, file_space_id, 'H5P_DEFAULT', d);

            % Clean up
            H5S.close(mem_space_id);
            H5S.close(file_space_id);
            H5D.close(data_id);
        end

        function appendImage(obj, imgPath, img)
            % Append one or more images
            if ~iscell(img)
                img = {img};
            end
            N = numel(img);

            % Consistency checks
            matrix_size = cell2mat(cellfun(@(x) x.head.matrix_size, reshape(img, [numel(img), 1]), 'UniformOutput', false));
            if any(diff(int32(matrix_size),1,1), 'all')
                error('All images must have the same matrix_size');
            end

            channels = cellfun(@(x) x.head.channels, img);
            if any(diff(int32(channels)))
                error('All images must have the same number of channels');
            end

            data_type = cellfun(@(x) x.head.data_type, img);
            if any(diff(int32(data_type)))
                error('All images must have the same data_type');
            end

            % Ensure group exists in file
            fullImgPath = strcat(obj.grouppath, '/', imgPath);  % e.g. /dataset/images_0

            lapl_id = H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, fullImgPath, lapl_id) == 0)
                group_id = H5G.create(obj.fid, fullImgPath, 0);
                H5G.close(group_id);
            end
            H5P.close(lapl_id);

            % ---------- ImageHeader ----------
            headPath = strcat(fullImgPath, '/', 'header');

            % Custom data type of the binary ImageHeader
            dtype = ismrmrd.util.hdf5_datatypes.getType_ImageHeader;

            lapl_id = H5P.create('H5P_LINK_ACCESS');

            % Check consistency of new images with existing images
            if (H5L.exists(obj.fid, headPath, lapl_id) ~= 0)
                % Read in a single header
                data_id = H5D.open(obj.fid, headPath);
                space_id = H5D.get_space(data_id);
                mem_space = H5S.create_simple(1,1,[]);
                H5S.select_hyperslab(space_id, 'H5S_SELECT_SET', [0], [1], [1], 1);
                currHead = H5D.read(data_id, dtype, mem_space, space_id, 'H5P_DEFAULT');

                H5S.close(mem_space);
                H5S.close(space_id);
                H5D.close(data_id);

                if any(int32(currHead.matrix_size) - int32(matrix_size(1,:))')
                    H5P.close(lapl_id);
                    error('New images must have the same matrix_size as existing images in this series');
                end

                if any(int32(currHead.channels) - int32(channels(1)))
                    H5P.close(lapl_id);
                    error('New images must have the same number of channels as existing images in this series');
                end

                if any(int32(currHead.data_type) - int32(data_type(1)))
                    H5P.close(lapl_id);
                    error('New images must have the same data_type as existing images in this series');
                end
            end

            if (H5L.exists(obj.fid, headPath, lapl_id) == 0)
                % No data exists in the file with this name
                dims    = [N];
                maxdims = [H5ML.get_constant_value('H5S_UNLIMITED')];
                space_id = H5S.create_simple(1, dims, maxdims);

                % Set chunking
                dcpl = H5P.create('H5P_DATASET_CREATE');
                H5P.set_chunk (dcpl, [198]); % 198 bytes for each ImageHeader

                data_id = H5D.create(obj.fid, headPath, dtype, space_id, dcpl);
                H5S.close(space_id);
            else
                % Existing data -- expand dimensions
                data_id = H5D.open(obj.fid, headPath);
                space_id = H5D.get_space(data_id);

                H5S.get_simple_extent_dims(space_id);
                [~,dims,~] = H5S.get_simple_extent_dims(space_id);
                dims = [dims(1)+N];
                H5D.set_extent(data_id, dims);
                H5S.close(space_id);
            end
            H5P.close(lapl_id);

            % Store the data
            space_id = H5D.get_space(data_id);
            [~,dims,~] = H5S.get_simple_extent_dims(space_id);

            % Select the last N block
            offset = [dims(1)-N];
            H5S.select_hyperslab(space_id,'H5S_SELECT_SET',offset,[1],[1],[N]);
            mem_space_id = H5S.create_simple(1,[N],[]);

            % Pack ImageHeader data for write
            head_data = ismrmrd.Dataset.CombineHDF5Header(cellfun(@(x) struct(x.head), img, 'UniformOutput', false));

            % Write
            H5D.write(data_id, dtype, mem_space_id, space_id, 'H5P_DEFAULT', head_data);

            % Clean up
            H5S.close(mem_space_id);
            H5S.close(space_id);
            H5D.close(data_id);

            % ---------- Image data ----------
            dataPath = strcat(fullImgPath, '/', 'data');

            imdim = double([channels(1) matrix_size(1,end:-1:1)]); % Reverse order for HDF5

            % Data type depends on the type of the images
            dtype = ismrmrd.util.hdf5_datatypes.getType_FromImageDataType(data_type(1));

            lapl_id = H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, dataPath, lapl_id) == 0)
                % No data exists in the file with this name
                dims    = [N imdim];
                maxdims = [H5ML.get_constant_value('H5S_UNLIMITED') imdim];
                space_id = H5S.create_simple(5, dims, maxdims);

                % Set chunking
                dcpl = H5P.create('H5P_DATASET_CREATE');
                H5P.set_chunk (dcpl, [1 imdim]);  % Chunk each image

                data_id = H5D.create(obj.fid, dataPath, dtype, space_id, dcpl);
                H5S.close(space_id);
            else
                % Existing data -- expand dimensions
                data_id = H5D.open(obj.fid, dataPath);
                space_id = H5D.get_space(data_id);

                H5S.get_simple_extent_dims(space_id);
                [~,dims,~] = H5S.get_simple_extent_dims(space_id);
                dims(1) = dims(1)+N;
                H5D.set_extent(data_id, dims);
                H5S.close(space_id);
            end
            H5P.close(lapl_id);

            % Store the data
            space_id = H5D.get_space(data_id);
            [~,dims,~] = H5S.get_simple_extent_dims(space_id);

            % Select the last N block
            offset = [dims(1)-N zeros(1,4)];
            H5S.select_hyperslab(space_id, 'H5S_SELECT_SET', offset, [], [], [N imdim]);

            dims    = [N imdim];
            maxdims = [H5ML.get_constant_value('H5S_UNLIMITED') imdim];
            mem_space_id = H5S.create_simple(5, dims, maxdims);

            % Stack data in the 5th dimension
            img_data = cell2mat(cellfun(@(x) x.data, reshape(img, [1 1 1 1 numel(img)]), 'UniformOutput', false));

            % Write
            H5D.write(data_id, dtype, mem_space_id, space_id, 'H5P_DEFAULT', img_data);

            % Clean up
            H5S.close(mem_space_id);
            H5S.close(space_id);
            H5D.close(data_id);

            % ---------- MetaAttributes ----------
            attrPath = strcat(fullImgPath, '/', 'attributes');

            % Data type is a variable length string with UTF-8 encoding
            dtype = H5T.copy('H5T_C_S1');
            H5T.set_size(dtype, 'H5T_VARIABLE');
                H5T.set_cset(dtype, H5ML.get_constant_value('H5T_CSET_UTF8'));

            lapl_id = H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, attrPath, lapl_id) == 0)
                % No data exists in the file with this name
                dims    = [N];
                maxdims = [H5ML.get_constant_value('H5S_UNLIMITED')];
                space_id = H5S.create_simple(1, dims, maxdims);

                % Set chunking
                dcpl = H5P.create('H5P_DATASET_CREATE');
                chunk = [1];
                H5P.set_chunk (dcpl, chunk);

                data_id = H5D.create(obj.fid, attrPath, dtype, space_id, dcpl);
                H5S.close(space_id);
            else
                % Existing data -- expand dimensions
                data_id = H5D.open(obj.fid, attrPath);
                space_id = H5D.get_space(data_id);

                H5S.get_simple_extent_dims(space_id);
                [~,dims,~] = H5S.get_simple_extent_dims(space_id);
                dims = [dims(1)+N];
                H5D.set_extent(data_id, dims);
                H5S.close(space_id);
            end
            H5P.close(lapl_id);

            % Store the data
            space_id = H5D.get_space(data_id);
            [~,dims,~] = H5S.get_simple_extent_dims(space_id);

            % Select the last N block
            offset = [dims(1)-N];
            H5S.select_hyperslab(space_id,'H5S_SELECT_SET',offset,[1],[1],[N]);
            mem_space_id = H5S.create_simple(1,[N],[]);

            % Pack MetaAttribute data for write
            attr_data = cellfun(@(x) x.attribute_string, img, 'UniformOutput', false);

            % Write
            H5D.write(data_id, dtype, mem_space_id, space_id, 'H5P_DEFAULT', attr_data);

            % Clean up
            H5S.close(mem_space_id);
            H5S.close(space_id);
            H5D.close(data_id);
        end

        function nacq = getNumberOfWaveforms(obj)

            % Check if the Data exists
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.waveformpath, lapl_id) == 0)
                error([obj.datapath ' does not exist in the HDF5 dataset.']);
            end
            dset = H5D.open(obj.fid, obj.waveformpath);
            space = H5D.get_space(dset);
            H5S.get_simple_extent_dims(space);
            [~,dims,~] = H5S.get_simple_extent_dims(space);
            nacq = dims(1);
            H5S.close(space);
            H5D.close(dset);

        end

        function block = readWaveform(obj, start, stop)
            if nargin == 1
                % Read all the acquisitions
                start = 1;
                stop = -1;
            elseif nargin == 2
                % Read a single acquisition
                stop = start;
            end

            % Check if the Data exists
            lapl=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.waveformpath, lapl) == 0)
                error([obj.waveformpath ' does not exist in the HDF5 dataset.']);
            end

            % Open the data
            dset = H5D.open(obj.fid, obj.waveformpath);

            % Open the data space
            space = H5D.get_space(dset);

            % Get the size
            [~,dims,~] = H5S.get_simple_extent_dims(space);
            nacq = dims(1);

            % Create a mem_space for reading
            if (stop >= start)
                offset = [start-1];
                dims = [stop-start+1];
                mem_space = H5S.create_simple(1,dims,[]);
            else
                offset = [0];
                dims = [nacq];
                mem_space = H5S.create_simple(1,dims,[]);
            end

            % Read the desired acquisitions
            H5S.select_hyperslab(space,'H5S_SELECT_SET',offset,[1],[1],dims);
            d = H5D.read(dset, obj.htypes.T_Waveform, ...
                         mem_space, space, 'H5P_DEFAULT');

            % Pack'em
            head = ismrmrd.Dataset.SplitHDF5Header(d.head, ismrmrd.WaveformHeader);
            block = cell(1, numel(head));
            for i = 1:numel(block)
                block{i} = ismrmrd.Waveform(head{i}, d.data{i});
            end

            % Clean up
            H5S.close(mem_space);
            H5S.close(space);
            H5D.close(dset);
        end

        function appendWaveform(obj, wav)
            % Append an acquisition

            % TODO: Check the type of the input

            % The number of acquisitions that we are going to append
            if ~iscell(wav)
                wav = {wav};
            end
            N = numel(wav);

            % Check if the Data exists
            %   if it does not exist, create it
            %   if it does exist increase it's size
            lapl_id=H5P.create('H5P_LINK_ACCESS');
            if (H5L.exists(obj.fid, obj.waveformpath, lapl_id) == 0)
                % Data does not exist
                %   create with rank 1, unlimited, and set the chunk size
                dims    = [N];
                maxdims = [H5ML.get_constant_value('H5S_UNLIMITED')];
                file_space_id = H5S.create_simple(1, dims, maxdims);

                dcpl = H5P.create('H5P_DATASET_CREATE');
                chunk = [1];
                H5P.set_chunk (dcpl, chunk);
                data_id = H5D.create(obj.fid, obj.waveformpath, ...
                                     obj.htypes.T_Waveform, ...
                                     file_space_id, dcpl);
                H5P.close(dcpl);
                H5S.close(file_space_id);

            else
                % Open the data
                data_id = H5D.open(obj.fid, obj.waveformpath);

                % Open the data space
                file_space_id = H5D.get_space(data_id);

                % Get the size, increment by N
                H5S.get_simple_extent_dims(file_space_id);
                [~,dims,~] = H5S.get_simple_extent_dims(file_space_id);
                dims = [dims(1)+N];
                H5D.set_extent (data_id, dims);
                H5S.close(file_space_id);

            end
            H5P.close(lapl_id);

            % Get the file space
            file_space_id = H5D.get_space(data_id);
            [~,dims,~] = H5S.get_simple_extent_dims(file_space_id);

            % Select the last N block
            offset = [dims(1)-N];
            H5S.select_hyperslab(file_space_id,'H5S_SELECT_SET',offset,[1],[1],[N]);

            % Mem space
            mem_space_id = H5S.create_simple(1,[N],[]);

            % Check and fix the acquisition header types

            % TODO: Error checking on the sizes of the data and trajectories.

            % Pack the acquisition into the correct struct for writing
            d = struct();
            d.head = ismrmrd.Dataset.CombineHDF5Header(cellfun(@(x) x.head, wav, 'UniformOutput', false));
            d.data = cellfun(@(x) x.data, wav, 'UniformOutput', false);

            % Write
            H5D.write(data_id, obj.htypes.T_Waveform, ...
                      mem_space_id, file_space_id, 'H5P_DEFAULT', d);

            % Clean up
            H5S.close(mem_space_id);
            H5S.close(file_space_id);
            H5D.close(data_id);
        end

        function delete(obj)
            H5F.close(obj.fid);
        end


    end

    methods (Static)
        function out = SplitHDF5Header(inStruct, outTemplate)
            % Split an HDF5 formatted multi-header into a cell array
            %
            % Header in HDF5 files are stored in an array that contain all measurements or
            % images, e.g.:
            %                    version: [4912×1 uint16]
            %      physiology_time_stamp: [3×4912 uint32]
            %                        idx: [1×1 struct]
            %
            % Split this into a cell array of class 'outTemplate', as MRD Acquisitions and
            % Images are stored indepdently.

            fields = fieldnames(inStruct);

            % Determine number of measurements.  This is somwhat complicated by the fact
            % that the dimension in which the repeats are store can be inconsistent, if
            % the header parameter has >1 value, e.g.:
            %                    version: [4912×1 uint16]
            %      physiology_time_stamp: [3×4912 uint32]
            sz = size(inStruct.(fields{1}));
            if (~ismatrix(sz))
                error('Could not determine number of measurements from field ''%s'' with size [%s]', fields{1}, num2str(sz, ' %d'))
            end

            if (sz(2) == 1)
                nMeas = sz(1);
            else
                nMeas = sz(2);
            end

            out = repmat({outTemplate}, [1 nMeas]);

            for iField = 1:numel(fields)
                if ~isstruct(inStruct.(fields{iField}))
                    sz = size(inStruct.(fields{iField}));
                    if (~ismatrix(sz))
                        error('Field ''%s'' has unsupported size [%s]', fields{1}, num2str(sz, ' %d'))
                    end

                    for iMeas = 1:nMeas
                        if (sz(2) == 1)
                            out{iMeas}.(fields{iField}) = inStruct.(fields{iField})(iMeas);
                        else
                            out{iMeas}.(fields{iField}) = inStruct.(fields{iField})(:,iMeas)';
                        end
                    end
                else
                    % Not a great generalizable way of doing this, but there's no other
                    % implicit way of determining the class of a sub-struct
                    if isfield(inStruct.(fields{iField}), 'kspace_encode_step_1')
                        outSub = ismrmrd.util.SplitGroupedHeader(inStruct.(fields{iField}), ismrmrd.EncodingCounters);
                        for iMeas = 1:nMeas
                            out{iMeas}.(fields{iField}) = outSub{iMeas};
                        end
                    end
                end
            end
        end

        function out = CombineHDF5Header(inCell)
            % Combine a cell array of structs into an HDF5 formatted multi-header
            %
            % In the MATLAB representation, a set of raw data/images/waveforms is stored
            % as a cell array of structs.  When writing to HDF5 files, the headers for
            % these objects must be converted into a single struct that contains all
            % measurements, e.g.:
            %                    version: [4912×1 uint16]
            %      physiology_time_stamp: [3×4912 uint32]
            %                        idx: [1×1 struct]

            out = struct(inCell{1});
            fields = fieldnames(out);

            for iField = 1:numel(fields)
                if ~isstruct(out.(fields{iField}))
                    if (numel(inCell{1}.(fields{iField})) == 1)
                        out.(fields{iField}) = cellfun(@(x) x.(fields{iField}), inCell)';
                    else
                        out.(fields{iField}) = cell2mat(cellfun(@(x) x.(fields{iField}), inCell, 'UniformOutput', false)')';
                    end
                else
                    out.(fields{iField}) = ismrmrd.Dataset.CombineHDF5Header(cellfun(@(x) x.(fields{iField}), inCell, 'UniformOutput', false));
                end
            end
        end
    end % methods (Static)
end
