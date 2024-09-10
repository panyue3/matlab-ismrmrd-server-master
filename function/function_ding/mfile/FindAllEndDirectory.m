
function [subdir, num] = FindAllEndDirectory(home)
% find all ending subdirectorys

indir = dir(home);
num = 0;
num_indir = length(indir);
subdir = cell(0);
for i = 1:num_indir
    if ( indir(i).isdir == 0 )
        continue;
    else
        if ( ~strcmp(indir(i).name, '.') & ~strcmp(indir(i).name, '..') )
            
            [subdir2, num2] = FindAllDirectory(fullfile(home, indir(i).name));
            
            if ( num2 > 0 )                
                for j=1:num2
                    num = num + 1;
                    subdir = [subdir {fullfile(indir(i).name, subdir2{j})}];                    
                end                
            else
                num = num + 1;
                subdir = [subdir {indir(i).name}];                
            end
        end
    end
end