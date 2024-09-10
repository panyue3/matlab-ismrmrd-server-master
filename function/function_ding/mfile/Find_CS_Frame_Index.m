
% function N_f = Find_CS_Frame_Index(N_index, N_per_frame)
% N_index:      Just a number
% N_per_frame:  two numbers, N_per_frame(1), first frame, N_per_frame(2),
% the rest frames

function N_f = Find_CS_Frame_Index(N_index, N_per_frame)

N_0 = length(N_index);
N_f = ones(1, N_0);

if length(N_per_frame)~=2
    disp('Error! Length(N_per_frame) != 2 !')
    return
end 

for i=1:N_0
    N_1 = N_index(i);
    if N_1 <= N_per_frame(1)
        N_f(i) = 1;
    else
        N_f(i) = floor((N_1 - N_per_frame(1)-1)/N_per_frame(2))+2;
    end
end
        











