
function [subdir, num] = FindAllDirectory(home)
% find all subdirectorys

indir = dir(home);
num = 0;
num_indir = length(indir);
subdir = cell(0);
for i = 1:num_indir
    if ( indir(i).isdir == 0 )
        continue;
    else
        if ( strcmp(indir(i).name, '.')==0 & strcmp(indir(i).name, '..')==0 )
            num = num + 1;
            subdir = [subdir {indir(i).name}];
        end
    end
end