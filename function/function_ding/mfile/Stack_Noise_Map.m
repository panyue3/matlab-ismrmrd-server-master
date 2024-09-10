
% [Noise_Map, Noise_Corr] = Stack_Noise_Map(a_0, varargin)
% Noise_Map: Noise variance map
% Noise_Corr: Image Intensity correction to make noise uniform, it is a
% corrected noise std map
% 

function [Noise_Map, Noise_Corr] = Stack_Noise_Map(a_0, varargin)

s_0 = size(a_0);
s_original = s_0;

x_step = 4;
y_step = 4;
x_win = 32;
y_win = 32;
t_win = 4;

if nargin == 2  % If there are two input variables
    option = varargin{1};
    if isfield(option, 'x_step') % Temporal window
        x_step = option.x_step;
    end
    if isfield(option, 'y_step') % Step size in the first dimension
        y_step = option.y_step;
    end
    if isfield(option, 'x_win') % Step size in the second dimension
        x_win = option.x_win;
    end
    if isfield(option, 'y_win') % Step size in both dimensions
        y_win = option.y_win;
    end
    if isfield(option, 't_win') % Step size in both dimensions
        t_win = option.t_win;
    end
end

N_xstep = ceil((s_0(1))/x_win);
N_ystep = ceil((s_0(2))/y_win);

t_x = N_xstep*x_win;
t_y = N_ystep*y_win;

if t_x > s_0(1)
    a_0(s_0(1)+1:t_x, :, :) = a_0(1:(t_x-s_0(1)), :, :);
    s_0(1) = t_x;
end
if t_y > s_0(2)
    a_0(:, s_0(2)+1:t_y, :) = a_0(:, 1:(t_y-s_0(2)), :);
    s_0(2) = t_y;
end
% Initialize the noise map
Noise_Map = zeros(s_0);

N_pixel = x_win*y_win;
N_block = N_xstep*N_ystep;
% T_win = 

% Average Template

tic
b = zeros(x_win*y_win, N_block, s_0(3));
temp_map = zeros(s_0);

for j=x_step:x_step:x_win
    for k=y_step:y_step:y_win
        for i=1:s_0(3)
            b(:,:,i) = im2col(circshift(a_0(:,:,i), [j, k]), [x_win, y_win], "distinct");
        end
        for i=1:s_0(3)-t_win+1
            d = permute(b(:,:,i:i+t_win-1), [1,3,2]);
            s = pagesvd(pagemtimes(pagectranspose(d), d) )/N_pixel;
            temp_std = ones(N_pixel, 1)*squeeze(s(end, :, :))';
            temp_map(:,:,i:i+3) = temp_map(:,:,i:i+t_win-1) + circshift( col2im(temp_std,[x_win, y_win],[s_0(1), s_0(2)],'distinct'), [-j, -k]) ;
        end
    end
end
toc
N_rep = x_win*y_win/x_step/y_step;
N_ave = t_win*ones(s_0(3), 1); N_ave(1:t_win-1) =1:t_win-1; N_ave(end:-1:end-t_win+2) = 1:t_win-1;

for i = 1:s_0(3)
    Noise_Map(:,:,i) = temp_map(:,:,i)/N_rep/N_ave(i);
end

mask_k = zeros(s_0(1), s_0(2));
mask_k(s_0(1)/2+[-N_xstep+1:N_xstep], s_0(2)/2+[-N_ystep+1:N_ystep]) = 1;
Noise_Map = abs(ifft2c( fft2c(Noise_Map).*mask_k ));

Noise_Map = Noise_Map(1:s_original(1), 1:s_original(2), :);

temp = abs(Noise_Map).^0.5;
mean_std = mean(temp(:));

Noise_Corr = temp + 0.1*mean_std*(1-1./(1 + exp(-(temp-mean_std))));

%figure(1), imagesc([temp(:,:,10), Noise_Corr(:,:,10), Noise_Corr(:,:,10)-temp(:,:,10)]), axis image, colorbar


return 

