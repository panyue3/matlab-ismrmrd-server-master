% This is the script to readin the dicom file.
% a = my_dicom_read(start,end,number_length)
% The file name should be Image(number), the start is the start number the
% end is the end number and number_length is the number of digits in the
% file name.

function a = my_dicom_read(start,step,last,name_length)

x = [0 name_length 'd'];
cc = sprintf('%%%d.%d%s',x);

number = sprintf(cc,start);
name = sprintf('%s%s','Image',number);
m = dicomread(name);
[s_1,s_2] = size(m);
s_3=length(start:step:last);
a = ones(s_1,s_2,s_3);
j=0;
for i = start:step:last
    j = j +1;
    number = sprintf(cc,i);
    name = sprintf('%s%s','Image',number);
    a(1:s_1,1:s_2,j) = dicomread(name);
    imagesc(a(:,:,j)), title(name),colormap(gray), axis xy, axis image, axis off, %pause(0.01)
end

