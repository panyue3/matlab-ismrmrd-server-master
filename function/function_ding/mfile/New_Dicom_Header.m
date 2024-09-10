% this is to perturb the dicom headers, make it looks like a new series of
% the same patient.
% function f_info = New_Header(f_info, I, n)
% f_info:   the dicom info in matlab structure array format
% I:        The Instance Number you want to start from
% n:        new Image series #

function f_info = New_Dicom_Header(f_info, I, n)

L = length(I);
if L==1,
    J = ones(1, length(f_info));
    for i=1:length(f_info)
        J(i) = i + I ;
    end
elseif L == length(f_info)
    J = I;
else
    'Error! Wronge New Instance Number!'
    return
end

for i=1:length(f_info)
    if isfield(f_info(i), 'SliceLocation'), f_info(i).SliceLocation = f_info(i).SliceLocation + rand; end
    f_info(i).SeriesNumber = n;
    f_info(i).SeriesDescription = num2str(n);
    f_info(i).ProtocolName = num2str(n);
    f_info(i).InstanceNumber = J(i);
    f_info(i).AcquisitionNumber = J(i);
    f_info(i).SeriesTime = num2str(str2num(f_info(i).StudyTime) + 201);
    f_info(i).AcquisitionTime = num2str(str2num(f_info(i).SeriesTime) - 101);
    f_info(i).ContentTime = num2str(str2num(f_info(i).SeriesTime) - 51);
    f_info(i).SeriesInstanceUID = sprintf('%s%s',f_info(i).SeriesInstanceUID,'1');
    f_info(i).SOPInstanceUID = sprintf('%s%s',f_info(i).SOPInstanceUID,'1');
    %n_name = sprintf('144_%s%0.5d_2.IMA','Image_Filtered_050_',i);
    % Save all the images
    %dicomwrite(a_r(:,:,i), n_name, info);
end




