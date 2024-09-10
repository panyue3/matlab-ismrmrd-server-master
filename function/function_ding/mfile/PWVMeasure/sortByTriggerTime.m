function [ handles ] = sortByTriggerTime( handles)

% sort the files by the trigger time
num_files=length(handles.times);
sortedTime = sort(handles.times);

for(i=1:num_files)
    tempIndex = find(handles.times==sortedTime(i));
    sortedFiles{i,1}= handles.file_names{tempIndex,1};
end

handles.file_names=sortedFiles;
handles.times = sortedTime;
