function [y,info] = updateDicom_info( directory_name_in, directory_name_out )

direct = dir(directory_name_in);
mkdir(directory_name_out)

info_tmp = dicominfo([directory_name_in '\' direct(3).name]);
SeriesNumber = info_tmp.SeriesNumber + 100;
SeriesDescription = [info_tmp.SeriesDescription '_new'];
SeriesInstanceUID = dicomuid;
%StudyInstanceUID = dicomuid;

% Main loop for all the frames
for ind = 3:length(direct)
    
    % Get dicominfo
    info = dicominfo([directory_name_in '\' direct(ind).name]);
    y = (dicomread([directory_name_in '\' direct(ind).name]));

    % update Series Number, Description and Series UID
    info.SeriesNumber = SeriesNumber; % update instance number
    info.SeriesDescription =SeriesDescription;
    info.SeriesInstanceUID = SeriesInstanceUID;
    % info.StudyInstanceUID = StudyInstanceUID;

    dicomwrite(y,[directory_name_out '\' direct(ind).name], info,'CreateMode','Copy')

end

end