% This is to sort the dicom hearders using the InstanceNumber 
% ascending order
% d_info = Sort_Header_InstanceNumber(d_info)

function d_info = Sort_Header_InstanceNumber(d_info)

L = length(d_info);
for i=1:L
    for j=1:L-i
        if d_info(j).InstanceNumber > d_info(j+1).InstanceNumber
           temp = d_info(j+1);
           d_info(j+1) = d_info(j) ;
           d_info(j) = temp;
           %'swap'
        end
    end
end



