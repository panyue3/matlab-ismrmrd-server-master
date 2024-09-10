
close all, clear all

folder_name = uigetdir;
if folder_name == 0
    disp('User selected Cancel');
else
    disp(['User selected ', folder_name]);
end


cd(folder_name)
D = dir;
for idx_dir = 3:3%length(D)
    %if D(idx_dir).isdir
        %cd(D(idx_dir).name)
        cd('Magnitude')
        F_0 = dir;
        for idx_f = 3:length(F_0)
            temp = dicominfo(F_0(idx_f).name);
            fn_new = sprintf('MR%04d', temp.InstanceNumber);
            disp([pwd, ' ', F_0(idx_f).name, ' ', fn_new])
            movefile(F_0(idx_f).name, fn_new)
        end
        cd ..
        cd('Velocity')
        F_0 = dir;
        for idx_f = 3:length(F_0)
            temp = dicominfo(F_0(idx_f).name);
            fn_new = sprintf('MR%04d', temp.InstanceNumber);
            disp([pwd, ' ', F_0(idx_f).name, ' ', fn_new])
            movefile(F_0(idx_f).name, fn_new)
        end
        cd ..
        %cd ..
    %end
end










