

%anonymous_dicom


clear all,
[fname,pname] = uigetfile('*.*','Select one file among all filtes that you want to filter');
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

cd(pname) % cd the file directory
delete anonymous
mkdir anonymous

h = waitbar(0,'Loading Dicom files. Please wait...', 'name', 'Loading');
t0 = dicomread( sprintf('%s%s',pname,fnames(n_j(2)).name) );


k = 1 ;
s_order = 0;
for i=1:l_names
    t_info = dicominfo( sprintf( '%s%s',pname,fnames(n_j(i)).name ) ); 
    t_info.PatientName.FamilyName = 'Family Name';
    t_info.PatientName.GivenName = 'Given Name';
    t_info.PatientID = '123456';
    t_info.PatientBirthDate = '19800101'
    temp = dicomread( sprintf( '%s%s',pname,fnames(n_j(i)).name ) );
    dicomwrite(temp, sprintf( '%s%sAnonymous_%s',pname,'anonymous\',fnames(n_j(i)).name ), t_info, 'CreateMode', 'copy' );
    temp = 0;
    t_info = 0;
    waitbar(i/l_names);
end
close(h)

%save(sprintf('%s%s',pathname, filename))



