classdef server < handle

    properties
        port           = [];
        tcpHandle      = [];
        log            = [];
        savedata       = false;
        savedataFolder = '';
    end

    methods
        function obj = server(port, log, savedata, savedataFolder)
            log.info('Starting server and listening for data at %s:%d', '0.0.0.0', port);

            if (savedata)
                log.info("Saving incoming data is enabled.")
            end

            obj.port           = port;
            obj.log            = log;
            obj.savedata       = savedata;
            obj.savedataFolder = savedataFolder;
        end

        function serve(obj)
            while true
                try
                    obj.tcpHandle = tcpip('0.0.0.0',          obj.port, ...
                                          'NetworkRole',      'server', ...
                                          'InputBufferSize',  32 * 2^20 , ...
                                          'OutputBufferSize', 32 * 2^20, ...
                                          'Timeout',          3000);  %#ok<TNMLP>  Consider moving toolbox function TCPIP out of the loop for better performance
                    obj.log.info('Waiting for client to connect to this host on port : %d', obj.port);
                    fopen(obj.tcpHandle);
                    obj.log.info('Accepting connection from: %s:%d', obj.tcpHandle.RemoteHost, obj.tcpHandle.RemotePort);
                    handle(obj);
                    flushoutput(obj.tcpHandle);
                    fclose(obj.tcpHandle);
                    delete(obj.tcpHandle);
                    obj.tcpHandle = [];
                catch ME
                    if ~isempty(obj.tcpHandle)
                        fclose(obj.tcpHandle);
                        delete(obj.tcpHandle);
                        obj.tcpHandle = [];
                    end

                    obj.log.error(sprintf('%s\nError in %s (%s) (line %d)', ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ME.stack(1).('line')));
                end
                pause(1)
            end
        end

        function handle(obj)
            try
                conn = connection(obj.tcpHandle, obj.log, obj.savedata, '', obj.savedataFolder);
                config = next(conn);
                metadata = next(conn);

                try
                    metadata = ismrmrd.xml.deserialize(metadata);
                    if ~isempty(metadata.acquisitionSystemInformation.systemFieldStrength_T)
                        tmp = split(metadata.measurementInformation.measurementID,'_');
                        obj.log.info("MID%05i data is from a %s %s at %1.1fT", str2double(tmp{end}), metadata.acquisitionSystemInformation.systemVendor, metadata.acquisitionSystemInformation.systemModel, metadata.acquisitionSystemInformation.systemFieldStrength_T)
                    end
                catch
                    obj.log.info("Metadata is not a valid MRD XML structure.  Passing on metadata as text")
                end

                % Decide what program to use based on config
                % As a shortcut, we accept the file name as text too.
                % ------------------------------------------------------- prompt ---------------------------------------------------------- %
                if strcmpi(config, "prompt")
                    if metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTcalibrate'))).value
                        obj.log.info("Starting prompt_calibrate processing based on config")
                        recon = prompt_calibrate;
%                         recon = prompt;
                    else
                        if logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'KWfilter'))).value)
                            obj.log.info("Starting prompt_mstar processing based on config")
                            % recon = prompt_kwfilter;
                            recon = prompt_mstar;
                        elseif ispc || logical(metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'PTRTFB'))).value)
                            obj.log.info("Starting prompt_rtfb processing based on config")
                            %recon = prompt_rtfb;
                            recon = getpmu;
                        else % Dummy loop with no processing
                            try
                                while true
                                    item = next(conn);
                                    if isempty(item)
                                        break;
                                    end
                                end
                                conn.send_close();
                            catch
                                conn.send_close();
                            end
                        end
                    end
                % --------------------------------------------------- prompt_map ------------------------------------------------------- %
                elseif strcmpi(config, "prompt_map")
                    obj.log.info("Starting prompt_map processing based on config")
                    recon = prompt_map;
                % ------------------------------------------------------------------------------------------------------------------------- %
                elseif strcmpi(config, "getpmu")
                    obj.log.info("Starting getpmu processing based on config")
                    recon = getpmu;
                elseif strcmpi(config, "invertcontrast")
                    obj.log.info("Starting invertcontrast processing based on config")
                    recon = invertcontrast;
                elseif strcmpi(config, "mapvbvd")
                    obj.log.info("Starting mapvbvd processing based on config")
                    recon = fire_mapVBVD;
                elseif strcmpi(config, "savedataonly")
                    % Dummy loop with no processing
                    try
                        while true
                            item = next(conn);
                            if isempty(item)
                                break;
                            end
                        end
                        conn.send_close();
                    catch
                        conn.send_close();
                    end
                else
                    if exist(config, 'class')
                        obj.log.info("Starting %s processing based on config", config)
                        eval(['recon = ' config ';'])
                    else
                        obj.log.info("Unknown config '%s'.  Falling back to 'invertcontrast'", config)
                        recon = invertcontrast;
                    end
                end

                if exist('recon','var')
                    recon.process(conn, config, metadata, obj.log);
                end

            catch ME
                cStr = cat(1, sprintf('%s\n', ME.message), arrayfun(@(x) sprintf('  In %s (line %d)\n', x.name, x.line), ME.stack, 'UniformOutput', false));
                str = [cStr{:}];
                obj.log.error(str);
                conn.send_text(cat(2, 'ERROR   ', str))
                conn.send_close();
                rethrow(ME);
            end

            if (conn.savedata)
                % Dataset may not be closed properly if a close message is not received
                if (~isempty(conn.dset) && H5I.is_valid(conn.dset.fid))
                    conn.dset.close()
                end

                if (isempty(conn.savedataFile) && exist(conn.mrdFilePath, 'file'))
                    try
                        % Rename the saved file to use the protocol name
                        info = h5info(conn.mrdFilePath);
                        
                        % Check if the group exists
                        indGroup = find(strcmp(arrayfun(@(x) x.Name, info.Groups, 'UniformOutput', false), strcat('/', conn.savedataGroup)), 1);
                        
                        % Check if xml exists
                        xmlExists = any(strcmp(arrayfun(@(x) x.Name, info.Groups(indGroup).Datasets, 'UniformOutput', false), 'xml'));

                        if (xmlExists)
                            dset = ismrmrd.Dataset(conn.mrdFilePath, conn.savedataGroup);
                            xml  = dset.readxml();
                            dset.close();
                            mrdHead = ismrmrd.xml.deserialize(xml);
                            
                            if ~isempty(mrdHead.measurementInformation.protocolName)
                                newFilePath = strrep(conn.mrdFilePath, 'MRD_input_', strcat(mrdHead.measurementInformation.protocolName, '_'));
                                movefile(conn.mrdFilePath, newFilePath);
                                conn.mrdFilePath = newFilePath;
                            end
                        end
                    catch
                        obj.log.error('Failed to rename saved file %s', conn.mrdFilePath);
                    end
                end

                if ~isempty(conn.mrdFilePath)
                    obj.log.info("Incoming data was saved at %s", conn.mrdFilePath)
                end
            end
        end

        function delete(obj)
            if ~isempty(obj.tcpHandle)
                fclose(obj.tcpHandle);
                delete(obj.tcpHandle);
                obj.tcpHandle = [];
            end
        end

    end

end
