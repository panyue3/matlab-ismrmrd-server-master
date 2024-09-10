function [ b ] = corr_filter( handles, x, y )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

[len temp] = size(handles.file_names);
a=[];

h = waitbar(0,'Loading Images. Please wait...', 'name', 'Load');
for i=1:len
    
    tempImage = getImage(fullfile(handles.vel_file_path, handles.file_names{i,1}), 'vel', handles.alias_adjust);
    a(:,:,i) = tempImage;
    waitbar(i/len);
end
close(h);

s = size(a);

v_0(1:s(3)) = a(x, y, 1:s(3));

b = zeros(s(1),s(2));

        
% a waitbar is a status bar. see the matlab help.
h = waitbar(0,'Computing the Correlation. Please wait...', 'name', 'Correlation');
for i= 1:s(1)
    for j=1:s(2)
        temp(1:s(3)) = a(i,j,1:s(3));
        m = max(abs(my_xcorr(temp',v_0' )));
        b(i,j) = m(1);
    end  
    waitbar(i/s(1));
end
close(h);