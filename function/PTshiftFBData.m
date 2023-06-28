classdef PTshiftFBData < handle
    properties
        shiftVec = single(nan(1,3));
    end

    methods
        function obj = PTshiftFBData(data, logging)
            if nargin > 0
                if numel(data) ~= 3
                    logging.error('Size of predicted PT shift vector incorrect, expected: 3, received: %i.', numel(data))
                else
                    obj.shiftVec = single(data);
                end
            end
        end

        function bytes = serialize(obj)
            bytes = typecast(obj.shiftVec,'uint8');

            if (numel(bytes) ~= 12)
                error('Serialized ImageHeader is %d bytes instead of 198 bytes', numel(bytes));
            end
        end
    end

end