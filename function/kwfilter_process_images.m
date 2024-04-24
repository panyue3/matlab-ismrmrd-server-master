function [images, data] = kwfilter_process_images(group, metadata, logging)

% Extract image data
cData = cellfun(@(x) x.data, group, 'UniformOutput', false);
data = cat(3, cData{:});
s_a = size(data);
% Sorting Images
logging.info('Sorting Images ...')
for i=1:size(data,3)
    v_0(i, :) = group{i}.head.position;
end
v_1 = v_0(1, :) - v_0(2, :);
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
% Normalize and convert to short (int16)
%data = data .* (32767./max(data(:)));
%data = int16(round(data));
% Determine the optimal parameter
if max(s_a) > 256 %
    option.Win_L = 64;
    option.step_x = 4;
    option.step_y = 4;
else
    option.Win_L = 32;
    option.step_x = 2;
    option.step_y = 2;
end
a_f = zeros(s_a);
%             if (s_a(3) > 20) && (s_a(3) < 37)
%                 disp('Separate odd/even ...')
%                 a_f(:,:,1:2:end) = KW_Patch_Filter_Adam(double(data(:,:,1:2:end)), option);
%                 a_f(:,:,2:2:end) = KW_Patch_Filter_Adam(double(data(:,:,2:2:end)), option);
%             else
logging.info('Lump together ...')
delete(gcp('nocreate'));  % Delete the current parallel pool
if isunix
    parpool(20);         % Create a new parallel pool with 'newSize' workers
else
    parpool;
end
% a_f = KW_Patch_Filter_Adam(double(data), option);
% a_f = single(KW_Patch_Filter_Adam_Slide(double(data), option));
a_f = single(KW_Patch_Filter_Adam_Slide_Neigh(double(data), option));
%             end
% Invert image contrast
%data = int16(abs(32767-data));

logging.info('Restore Order ...')
data(:,:,J) = uint16(a_f);

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

logging.info('Save data with slice poition ...')
save(['output\Temp_Data_0', datestr(now, 'yyyy_mm_dd_HH_MM_SS'), '.mat'], 'data_0', 'a_f', 'v_0', 'v_re', 'b', 'J', 'images', 'metadata', 'option')

end