
% [a_f, Noise_map] = KW_Patch_Filter_Adam_Slide_Multiple(a_0, varargin)
% comparing to KW_Patch_Filter_Adam_Slide, this function register patches
% mutiple times and filter it multiple times

function [a_f, Noise_map] = KW_Patch_Filter_Adam_Slide_Multiple_Neigh(a_0, varargin)

a_0 = a_0 + (a_0==0).*rand(size(a_0))*0.1;
% check input data size
s_0 = size(a_0);
N_fe = s_0(1);
N_pe = s_0(2);
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
if s_0(3) < 27
    T_win = s_0(3);
    T_step = T_win;
else
    T_win = 16;
    T_step = 8;
end

Tot_step_x = length(1:step_x:s_0(1));
Tot_step_y = length(1:step_y:s_0(2));
N_fr = T_win;
N_sw = Tot_step_x*Tot_step_y*T_win; % N_sw = Tot_step_x*Tot_step_y; 20231228


for k= 1:T_step:s_0(3)
    tic
    t_ind = mod((k:k+T_win-1)-1,s_0(3))+1;
    
    a_1 = (double(a_0(:,:,t_ind)));
    data_temp = zeros(Win_L, Win_L, T_win,  T_win, Tot_step_x, Tot_step_y);
    filt_temp = zeros(Win_L, Win_L, T_win, N_sw);
    bp_x = zeros(Win_L, N_fr, T_win, Tot_step_x, Tot_step_y);
    bp_y = zeros(Win_L, N_fr, T_win, Tot_step_x, Tot_step_y);
    var_0 = zeros(1, N_sw);    
    t_filtered = zeros(s_0(1), s_0(2), T_win); % 20231228
    T_weight(t_ind) = T_weight(t_ind) + 1;
    a_weight = zeros(s_0(1), s_0(2), T_win);
    Recon_1 = a_1; 

    parfor j= 1:Tot_step_y%1:step_x:s_0(1)
        y_start = (j-1)*step_y + 1;
        y_ind = mod((y_start:y_start+Win_L-1)-1, N_pe)+1;         
        for i=1:Tot_step_x%1:step_y:s_0(2)             
            x_start = (i-1)*step_x + 1;
            x_ind = mod((x_start:x_start+Win_L-1)-1, N_fe)+1;
            % Align up patches by searching around the mean
            %tic
            %[data_temp(:,:,:,i,j), bp_x(:,:,i,j), bp_y(:,:,i,j)] = Align_Patch(Recon_1, x_ind, y_ind) ; 
            [data_temp(:,:,:,:,i,j), bp_x(:,:,:,i,j), bp_y(:,:,:,i,j)] = Multiple_Alignment(Recon_1, x_ind, y_ind) ; % 20231228  
            %toc             
        end
    end
    data_temp = reshape(data_temp, [Win_L, Win_L, T_win, N_sw]);
    parfor i=1:N_sw
        %filt_temp(:,:,:,i) = KW_Filter(data_temp(:,:,:,i)); KW_Filter_Adam
        [filt_temp(:,:,:,i), var_0(i)] = KW_Filter_Adam_Neigh(data_temp(:,:,:,i)); 
    end
    filt_temp = reshape(filt_temp, [Win_L, Win_L, T_win, T_win, Tot_step_x, Tot_step_y]);
    for i=1:Tot_step_x
        for j=1:Tot_step_y
            for k = 1:N_fr
                for l = 1:T_win
                    x_ind = bp_x(:, k, l, i, j);
                    y_ind = bp_y(:, k, l, i, j);
                    t_filtered(x_ind, y_ind, k) = t_filtered(x_ind, y_ind, k) + filt_temp(:, :, k, l, i, j) ;
                    a_weight(x_ind, y_ind, k) = a_weight(x_ind, y_ind, k) + 1;
                end
            end
        end
    end
    % get rid of zeros in the spatial weighting array
    a_weight(a_weight == 0) = 1; 
    a_f(:,:,t_ind) = a_f(:,:,t_ind) + t_filtered./a_weight;

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

% get rid of zeros: 20231228
N_0 = find(a_f==0);
if N_0
    a_f(a_f==0) = a_0(a_f==0);
end

return



