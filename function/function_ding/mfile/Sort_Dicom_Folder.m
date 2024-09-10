

% Read all files from the dicom folder
% Sort them using image series #, 
% Save them in sub-folders

clear all,
current_path = pwd; 
[fname,pname] = uigetfile('*.*','Select one file among all files that you want to read');
fnames = dir(pname);
l_name = length(fnames);
j = 0;
for i=1:l_name % find all the files
    if (fnames(i).isdir==0)&(~strcmp(fnames(i).name,'DICOMDIR'))&(~strcmp(fnames(i).name,'dicomdir'))&(~strcmp(fnames(i).name,'Dicomdir')) 
        n_j(j+1) = i;
        j = j+1;
    end
end
l_names = length(n_j); % file names

cd(pname) % cd the Dicom file directory 

%t_info = struct([])
h = waitbar(0,'Loading Dicom Info. Please wait...', 'name', 'Loading');
for i=1:l_names
    %t_info(i) = dicominfo( sprintf( '%s%s',pname,fnames(n_j(i)).name ) ); 
    t_info = dicominfo(fnames(n_j(i)).name ); 
    Series_Number(i) = t_info.SeriesNumber; 
    Instance_Number(i) = t_info.InstanceNumber; 
    waitbar(i/l_names); 
end 
close(h) 

% make directories 
for i=1:max(Series_Number) 
    if find(Series_Number == i )  
        mkdir(sprintf( '%03d',i)) 
    end 
end 

% move files
h = waitbar(0,'Moving Dicom Files. Please wait...', 'name', 'Moving');
for i=1:l_names
    %movefile(fnames(n_j(i)).name, sprintf('%03d/%s', Series_Number(i),fnames(n_j(i)).name ))
    movefile(fnames(n_j(i)).name, sprintf('%03d/%03d.ima', Series_Number(i),Instance_Number(i) ))
    waitbar(i/l_names);
end
close(h)
% back to original folder
cd(current_path)



