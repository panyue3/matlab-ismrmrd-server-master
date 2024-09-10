function [images, data] = mstar_process_images(group, metadata, logging)

% Extract image data
cData = cellfun(@(x) x.data, group, 'UniformOutput', false);
data = cat(3, cData{:});

% Sorting Images
logging.info('Sorting Images ...')
v_0 = cell2mat(cellfun(@(x) x.head.position, group, 'UniformOutput', false)');
v_1 = v_0(1, :) - v_0(2, :);
b = nan(1,size(v_0,1));
b(1) = 0;
for i = 2:size(v_0, 1)
    v_2 = v_0(1,:) - v_0(i, :);
    b(i) = sum(v_1.*v_2);
end
[~, J] = sort(b);
logging.info('New Order: %s', join(string(J),', '))
data = data(:,:,J);
data_0 = data;

logging.info('data size = %s', join(string(size(data)),', '))
logging.info('Filtering Images, I run ...')

data = single(KW_Patch_Filter_Adam_Slide_Neigh(single(data)));

logging.info('Restore Order ...')
data(:,:,J) = uint16(data);

% Slice to volume registration:
Win_SL = 4;
option.Window = Win_SL;
data = LGE_MSTAR(data, [], option); 

% Re-slice back into 2D MRD images
images = cell(1, size(data,3));
for iImg = 1:size(data,3)
    % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
    image = ismrmrd.Image(data(:,:,iImg));

    % Copy original image header, but keep the new data_type and channels
    newHead = image.head;
    image.head = group{J(iImg)}.head;
    image.head.data_type = newHead.data_type;
    image.head.channels  = newHead.channels;

    % Add to ImageProcessingHistory
    meta = ismrmrd.Meta.deserialize(group{J(iImg)}.attribute_string);
    meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'MSTAR Registration');
    temp_SequenceDescription = meta.SequenceDescription;
    meta.SequenceDescription = [temp_SequenceDescription, '_MSTAR'];

    image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));
    images{iImg} = image;
end
v_re = cell2mat(cellfun(@(x) x.head.position, images, 'UniformOutput', false)');

logging.info('Save data with slice poition ...')
save(fullfile(pwd,'output',['Temp_Data_0', datestr(now, 'yyyy_mm_dd_HH_MM_SS'), '.mat']), 'data_0', 'data', 'v_0', 'v_re', 'b', 'J', 'images', 'metadata', 'option')

end