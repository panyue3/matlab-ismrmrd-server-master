

function [a_f, Noise_map] = KW_Patch_Filter_Adam(a_0, varargin)

% check input data size
s_0 = size(a_0);
if length(s_0) ~=3
    disp('Input data MUST be a 3-D Array!')
    a_f = a_0;
    return
end
% set default parameters
step_x = 4;
step_y = 4;
Win_L = 32;
T_win = min([24, s_0(3)]);

wname = 'db1';  % Default

T_weight = zeros(s_0(3), 1);
a_f = zeros(s_0);
a_weight = zeros(s_0(1), s_0(2));

% set parameter from nargin
if nargin == 2  % If there are two input variables
    option = varargin{1};
    if isfield(option, 'T_win') % Temporal window
        T_win = option.T_win;
    end
    if isfield(option, 'step_x') % Step size in the first dimension
        step_x = option.step_x;
    end
    if isfield(option, 'step_y') % Step size in the second dimension
        step_y = option.step_y;
    end
    if isfield(option, 'step_size') % Step size in both dimensions
        step_y = option.step_size;
        step_x = step_y;
    end
    if isfield(option, 'Win_L') % Step size in the second dimension
        Win_L = option.Win_L;
    end
    if isfield(option, 'WaveletName')
        wname = option.WaveletName;
    end
end
T_win = min([T_win, s_0(3)]);
if s_0(3) < 31
    T_win = s_0(3);
    T_step = T_win;
else
    T_win = 24;
    T_step = 8;
end

N_sw = length(1:step_x:s_0(1))*length(1:step_y:s_0(2));

% find the spatial weight from filtering 
for i=1:step_x:s_0(1)
    x_ind = mod((i:i+Win_L-1)-1,s_0(1))+1;
    for j=1:step_y:s_0(2)         
        y_ind = mod((j:j+Win_L-1)-1,s_0(2))+1;         
        a_weight(x_ind, y_ind) = a_weight(x_ind, y_ind) + 1;
    end
end


for k= 1:T_step:s_0(3)
    tic
    t_ind = mod((k:k+T_win-1)-1,s_0(3))+1;
    
    a_1 = (double(a_0(:,:,t_ind)));
    data_temp = zeros(Win_L, Win_L, T_win, N_sw);
    filt_temp = zeros(Win_L, Win_L, T_win, N_sw);
    var_0 = zeros(1, N_sw);    
    t_filtered = zeros(size(a_1));
    T_weight(t_ind) = T_weight(t_ind) + 1;
    Recon_1 = a_1; 

    count_b = 0;
    for i=1:step_x:s_0(1)
        x_ind = mod((i:i+Win_L-1)-1,s_0(1))+1;
        for j=1:step_y:s_0(2)
            count_b = count_b + 1;
            y_ind = mod((j:j+Win_L-1)-1,s_0(2))+1;
            data_temp(:,:,:, count_b) = Recon_1(x_ind, y_ind, :);             
        end
    end

    parfor i=1:N_sw
        %filt_temp(:,:,:,i) = KW_Filter(data_temp(:,:,:,i)); KW_Filter_Adam
        [filt_temp(:,:,:,i), var_0(i)] = KW_Filter_Adam(data_temp(:,:,:,i)); 
    end
    count_b = 0;
    for i=1:step_x:s_0(1)
        x_ind = mod((i:i+Win_L-1)-1,s_0(1))+1;
        for j=1:step_y:s_0(2)
            count_b = count_b + 1;
            y_ind = mod((j:j+Win_L-1)-1,s_0(2))+1;
            t_filtered(x_ind, y_ind,:) = t_filtered(x_ind, y_ind,:) + filt_temp(:, :, :, count_b) ;

        end
    end
    a_f(:,:,t_ind) = a_f(:,:,t_ind) + t_filtered./repmat(a_weight, [1, 1, T_win]);

    disp(k)
    toc,
    pause(0.1)
end
% Noise map 2023-09-21
count_b = 0;
Noise_map = zeros(s_0(1), s_0(2));
for i=1:step_x:s_0(1)
    x_ind = mod((i:i+Win_L-1)-1,s_0(1))+1;
    for j=1:step_y:s_0(2)
        count_b = count_b + 1;
        y_ind = mod((j:j+Win_L-1)-1,s_0(2))+1;
        Noise_map(x_ind, y_ind) = Noise_map(x_ind, y_ind) + var_0(count_b)*ones(Win_L,Win_L) ; 
    end
end
Noise_map = Noise_map./a_weight;


for i=1:s_0(3)
    a_f(:,:,i) = a_f(:,:,i)/T_weight(i);
end

return



