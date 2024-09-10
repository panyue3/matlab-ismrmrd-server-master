% Reshape the RawData
% Data = Reshape_RawData(RawData, asc);
% Data = Data(:, Kspace_Counter, Slice_Counter, Img_Counter, Chan_Counter)

function Data = Reshape_RawData(RawData, asc);

Chan_Num = asc(1).ushUsedChannels; % Total # of channels 
temp = asc(end).sLC;
Tot_Num = temp(6) + 1; % Total # of images
Tot_Sli = temp(3) + 1; % Total # of slices
S0 = size(RawData);
Tot_klines = floor( length(asc)/Chan_Num/Tot_Num/Tot_Sli ) ;
Data = zeros(S0(1), Tot_klines, Tot_Sli, Tot_Num, Chan_Num, 'single');

for i=1:length(asc),  temp = asc(i).sLC;
    Img_Counter    = temp(6)+1;
    Slice_Counter  = temp(3)+1;
    Kspace_Counter = temp(1)+1;
    Chan_Counter   = asc(i).ushChannelId + 1;
    Data(:, Kspace_Counter, Slice_Counter, Img_Counter, Chan_Counter) = RawData(:, i);
end

