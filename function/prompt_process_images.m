function [image, imdata] = prompt_process_images(group, metadata, logging, ref)

% Calculate image shift
if nargin < 4
    imdata  = calculateImageShift(group, metadata, logging);
else
    imdata  = calculateImageShift(group, metadata, logging, ref);
end

% Find end expiratory
imdata.endExp = median(findpeaks(imdata.shiftvec(:,3)));
logging.info('Training end expiratory amplitude: %.2f.', imdata.endExp)

% Pack cropped reference images
for ii = 1:size(imdata.ref_crop,3)
    if imdata.isFlip(ii)
        ima = ismrmrd.Image(transpose(single(imdata.ref_crop(:,:,ii))));
    else
        ima = ismrmrd.Image(single(imdata.ref_crop(:,:,ii)));
    end

    % Copy original image header, but keep the new data_type
    data_type = ima.head.data_type;
    ima.head = group{ii}.head;
    ima.head.data_type = data_type;
    ima.head.field_of_view = [group{ii}.head.field_of_view(1:2)./3, group{ii}.head.field_of_view(3)];
    ima.head.matrix_size = size(ima.data, [1 2 3]);

    % Add to ImageProcessingHistory
    meta = ismrmrd.Meta.deserialize(group{ii}.attribute_string);
    meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'PROMPT');
    ima = ima.set_attribute_string(ismrmrd.Meta.serialize(meta));
    image{ii} = ima;
end

% Save figure to output folder
fig = figure;
hold on
plot(imdata.shiftvec(:,1),'k:'); plot(imdata.shiftvec(:,2),'k--'); plot(imdata.shiftvec(:,3),'k');
xlim([0 size(imdata.shiftvec,1)]);
ylabel('Displacement (mm)'); title('Image Disp');
legend('dX','dY','dZ','Location','southoutside','NumColumns',3);
hold off
if nargin < 4
    figname = fullfile(pwd,'output','Train_Disp.png');
else
    figname = fullfile(pwd,'output','Test_Disp.png');
end
saveas(fig, figname)
close(fig)

data = uint16(255 - rgb2gray(imread(figname)))';
image{end+1} = pack_image(data, group{1});

end