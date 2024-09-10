
% function [k_space, k_space_down, asc] = Down_Sample_K_Space(k_space,option)
% k_space:      down-sampled k-space with zero-filling
% k_space_down: down-sampled k-space without zero-filling
% asc:          k-space acquisition patterns


function [k_space, k_space_down, asc] = Down_Sample_K_Space(k_space, option)

s_0 = size(k_space);
if length(s_0) == 2;
    s_0(3) = 1; s_0(4) = 1;
elseif length(s_0) == 3;
    s_0(4) = 1;
end
k_space_down = [];
asc = [];

if isfield(option, 'SamplingPattern')
    asc = option.SamplingPattern;
elseif isfield(option, 'sampling_location')
    asc = option.sampling_location;
elseif isfield(option, 'interleave')||isfield(option, 'Interleave')||isfield(option, 'Inter_Leave')
    if isfield(option, 'Acc')
        N = ceil(s_0(2)/option.Acc);
        asc = zeros(N, s_0(4));
        for i=1:s_0(4)
            Index = (mod(i-1, option.Acc)+1):option.Acc:s_0(2) ; 
            asc(1:length(Index), i) = Index ;
        end
    else
        disp('Error! No option.Acc Specified!')
        return,
    end
else
    disp('Error! Neither option.Acc nor option.SamplingPattern Specified!')
        return,
end

s_1 = s_0; s_1(2) = size(asc, 1);
temp = k_space; %figure(1), imagesc(SoS(temp(:,:,:,1)))
k_space = zeros(s_0,'single');
k_space_down = zeros(s_1, 'single');

%length(size(s_0))
%s_0
if length((s_0)) == 4, % 4-D array
    for i=1:s_0(4)
        k_space(:,asc(:,i),:,i) = temp(:,asc(:,i),:,i);
        k_space_down(:,:,:,i)   = temp(:,asc(:,i),:,i);
    end
elseif length((s_0)) == 5,
    for i=1:s_0(4)
        k_space(:,asc(:,i),:,i,:) = temp(:,asc(:,i),:,i,:);
        k_space_down(:,:,:,i,:)   = temp(:,asc(:,i),:,i,:);
    end
end



