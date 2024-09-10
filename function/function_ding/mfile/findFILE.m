
function [names, num] = findFILE(home, suffix)
% find all files with the suffix in directory home

pp = dir(fullfile(home, suffix));
num = numel(pp);

names = cell(num, 1);

for i=1:num
    names{i} = fullfile(home, pp(i).name);
end