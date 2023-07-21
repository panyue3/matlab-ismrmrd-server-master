classdef PTshiftFBData < handle
    properties
        shiftVec = single(nan(1,3));
        isSkipAcq = false;
    end

    methods
        function obj = PTshiftFBData(data, bvalue, logging)
            if nargin > 0
                if numel(data) ~= 3
                    logging.error('Size of predicted PT shift vector incorrect, expected: 3, received: %i.', numel(data))
                else
                    obj.shiftVec = single(data);
                end
                if numel(bvalue) ~= 1
                    logging.error('Size of logical data incorrect, expected: 1, received: %i.', numel(bvalue))
                else
                    obj.isSkipAcq = bvalue;
                end
            end
        end

        function bytes = serialize(obj)
            bytes = cat(2, typecast(obj.shiftVec,'uint8'), ...
                typecaat(obj.isSkipAcq, 'uint8'));

            if (numel(bytes) ~= 12)
                error('Serialized ImageHeader is %d bytes instead of 198 bytes', numel(bytes));
            end
        end
    end

end