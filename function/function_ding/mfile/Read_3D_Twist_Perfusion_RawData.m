
% [k_space, asc] = Read_3D_Twist_Perfusion_RawData(fname)
% 
% 

function [Raw_Data, Sampling_Location] = Read_3D_Twist_Perfusion_RawData(fname)

[Data, asc, prot] = Read_RawData(fname);
N_1 = length(asc);
slc = zeros(14, N_1);

N_skip = asc(1).ushUsedChannels;
s_1 = asc(1).ushSamplesInScan;

N_1 = length(asc)-2*N_skip;
PE_Index = zeros(1, N_1);
PT_Index = zeros(1, N_1);
FR_Index = zeros(1, N_1);

for i = ( N_skip+1 ):( length(asc)-N_skip ), 
    temp = asc(i).sLC;
    slc(:, i) = temp ;
    PE_Index( i ) = temp(1) ; 
    PT_Index( i ) = temp(4) ; 
    FR_Index( i ) = temp(7) ;
end

Raw_Data = zeros( s_1, max(PE_Index(:))+1, max(PT_Index(:))+1, N_skip, max(FR_Index(:))+1, 'single');
Sampling_Location = zeros(max(PE_Index(:))+1, max(PT_Index(:))+1, max(FR_Index(:))+1);

for index = ( N_skip+1 ):( length(asc)-N_skip )
    %size(Raw_Data(:, PE_Index(index)+1, PT_Index(index)+1, asc(index).ushChannelId+1, FR_Index(index)+1))
    %size(Data(:, index))
    %index, PE_Index(index)+1, PT_Index(index)+1, asc(index).ushChannelId+1, FR_Index(index)+1,
    Raw_Data(:, PE_Index(index)+1, PT_Index(index)+1, asc(index).ushChannelId+1, FR_Index(index)+1) = Data(:, index);
    if mod(index, N_skip) == 1
        Sampling_Location( PE_Index(index)+1, PT_Index(index)+1, FR_Index(index)+1 ) = 1 ;
    end
end

Noise_Scan = Data(:,1:N_skip);




