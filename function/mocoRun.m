function [images, data] = mocoRun(data)

if iscell(data)
    data = cellfun(@(x) x.data, data, 'UniformOutput', false);
    data = cat(3, data{:});
end
data = double(data .* (65535./max(data(:))));
[Dx,Dy] = mocoDisp(data, 1, 12);
data  = uint16(mocoApply(data, Dx, Dy));

images = cell(1, size(data,3));
for ii = 1:size(data,3)
    % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
    image = ismrmrd.Image(data(:,:,ii));

    % Copy original image header, but keep the new data_type
    data_type = image.head.data_type;
    image.head = group{ii}.head;
    image.head.data_type = data_type;

    % Add to ImageProcessingHistory
    meta = ismrmrd.Meta.deserialize(group{ii}.attribute_string);
    meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'MOCO');
    meta.SequenceDescription = [meta.SequenceDescription, '_PROMPT_MOCO'];
    image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

    images{ii} = image;
end

end
