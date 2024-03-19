
% Test lib for KW patch filter

close all, clear all
cd C:\MATLAB\work\Work_Space_Dual_CPU\2023\2023_07_31_Lib_for_KW_Filter

f_path = 'R:\CMRCT Lab Team\YuDing\RawData\20230718_PR101_0010\';

f_name{1} = 'series_09';
p_gcp = gcp,
for i=1:1
    load([f_path, f_name{i}])
    a_0 = double(a_0);
    s_0 = size(a_0);
    option.win_L = 80;
    option.step_size = 8;
    option.T_win = 25;
    a_f = KW_Patch_Filter(a_0, option);
    disp(std(a_0(:)-a_f(:)))
    for j=1:s_0(3), figure(1), imagesc([a_0(:,:,j), a_f(:,:,j), 4*abs(a_0(:,:,j)-a_f(:,:,j))]), axis image, title(num2str([i, j])), pause,end;
    
end










