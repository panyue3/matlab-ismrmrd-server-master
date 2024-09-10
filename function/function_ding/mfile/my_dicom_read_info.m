% This is the script to readin the dicom file with dicominfo.
% [a, t_info] = my_dicom_read_info(start,end,number_length)
% The file name should be Image(number), the start is the start number the
% end is the end number and number_length is the number of digits in the
% file name.
% With the dicom info also read out

function [a, t_info] = my_dicom_read_info(start,last,name_length)

x = [0 name_length 'd'];
cc = sprintf('%%%d.%d%s',x);

number = sprintf(cc,start);
name = sprintf('%s%s','Image',number);
m = dicomread(name);
[s_1,s_2] = size(m);
a = ones(s_1,s_2,last-start+1);

for i = start:last
    number = sprintf(cc,i);
    name = sprintf('%s%s','Image',number);
    a(1:s_1,1:s_2,i+1-start) = dicomread(name);
    t_info(i+1-start) = dicominfo(name);
%    imagesc(a(:,:,i+1-start)), title(name),colormap(gray), axis xy, axis image, axis off, %pause(0.01)
end
