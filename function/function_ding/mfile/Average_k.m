% Average k-space rawdata for reference image
% [k_ave, Sampling] = Average_k(data)
% data: input FExPExCHxPhs k-space data
% Sampling: 2-D (0, 1) valued matrix, size: PExPhs
% k_ave: average all phases. size: FExPExCH

function [k_ave, Sampling] = Average_k(data)

s_0 = size(data);

if (length(s_0) == 4)
    k_ave = sum(data, 4);
    temp = double(squeeze(std(squeeze(mean( data, 3 )))) > 0);
    
    for i = 1:s_0(4)
        Sampling(:,i) = find(temp(:,i) > 0.5);
    end
    pe_counter = sum(temp, 2);
    pe_counter(pe_counter == 0) = 1;
    for i=1:s_0(2)
        k_ave(:,i,:) = k_ave(:,i,:)/pe_counter(i);
    end

else
    k_ave = 0;
    disp('Input Data Must be 4-D, [FE, PE, CH, Phs]')
end
return















