
function [subdir, num] = FindAllDirectoryRecursive(home)
% find all subdirectorys

indir = dir(home);
num = 0;
num_indir = length(indir);
subdir = cell(0);
for i = 1:num_indir
    if ( indir(i).isdir == 0 )
        continue;
    else
        if ( ~strcmp(indir(i).name, '.') & ~strcmp(indir(i).name, '..') )
            num = num + 1;
            subdir = [subdir {indir(i).name}];
        end
    end
end