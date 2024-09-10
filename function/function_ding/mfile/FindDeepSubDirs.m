function deepSubDirs = FindDeepSubDirs(home, deepSubDirs, dirLength)
% find the most deepest subdirs

[subdirs, num] = FindSubDirs(home);

pp = find(home == '\');
if ( numel(pp) >= dirLength-1 )
    numDirs = numel(deepSubDirs);
    deepSubDirs{numDirs+1} = home;
    return;
end

if ( isempty(dirLength) )
    dirLength = 100;
end

if ( num>0)
    for i=1:num

        newhome = fullfile(home, subdirs{i});
        deepSubDirs = FindDeepSubDirs(newhome, deepSubDirs, dirLength);

    end
else
    numDirs = numel(deepSubDirs);
    deepSubDirs{numDirs+1} = home;
end