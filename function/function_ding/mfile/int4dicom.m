% convert double data to int16 for dicom format
% function data  = int4dicom(data)

function data  = int4dicom(data)

data(find(data<0)) = 0;
data(find(data>4095)) = 4095;
data = uint16(data);
