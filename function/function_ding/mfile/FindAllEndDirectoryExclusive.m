
function [subdir, num] = FindAllEndDirectoryExclusive(home, exDir)
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
            
            %[subdir2, num2] = FindAllDirectory(fullfile(home, indir(i).name));
            [subdir2, num2] = FindAllEndDirectory(fullfile(home, indir(i).name));
            
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

numExDir = numel(exDir);
subdir2 = [];
for kk = 1:num
    
    if ( numExDir <= 1 )
        ind=strfind(subdir{kk}, exDir{1});
    else
        for pp=1:numExDir
            ind=strfind(subdir{kk}, exDir{pp});
            if ( ind ~= 0 )
                break;
            end
        end
    end

    if ( ~isempty(ind) & ind ~= 0 )
        dirName = subdir{kk};
        pathName = {dirName(1:ind-2)};
        foundFlag = 0;
        for pp=1:numel(subdir2)
            if ( strcmp(subdir2{pp}, pathName) == 1 )
                foundFlag = 1;
                break;
            end
        end
        if ( foundFlag == 0 )
            subdir2 = [subdir2 pathName];
        end
        continue;
    end
    
    subdir2 = [subdir2 subdir(kk)];
end

subdir = subdir2;
num = numel(subdir2);


