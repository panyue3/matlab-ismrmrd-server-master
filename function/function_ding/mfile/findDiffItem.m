function allDiffItems = findDiffItem(items)

num = numel(items);

allDiffItems = [];
allDiffItems = items(1);

for k=2:num
    index = find(items(k)==allDiffItems);
    if ( isempty(index) )
       allDiffItems = [allDiffItems; items(k) ]; 
    end
end
