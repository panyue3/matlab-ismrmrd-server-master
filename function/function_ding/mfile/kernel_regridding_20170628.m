% New version of 2017-06-28
% The following are new features comparing to old version (kernel_regridding):
% 1. Regrid a line at one time, intead of a point
% 2. Including over-smapling option


% Regridding using pre-calculated kernel function 
% [k_out_nw, k_out_w, dcf] = kernel_regridding_20170628(x_in, y_in, kb, w, stepsize, x_1, y_1)
% x_in: input x-axis of a line, MUST be zero-centered
% y_in: input y-axis of a line, MUST be zero-centered
% x_1: output x-coordinate matrix 
% y_1: output x-coordinate matrix
% kb: Kaiser-Bessel kernel (circular shaped in a square domain, stepsize)
% w: Kaiser-Bessel kernel width
% stepsize: Sampling step size of Kaiser-Bessel kernel
% k_out_nw: output k-space matrix without radial linear weighting, 
% k_out_w: output k-space matrix with radial linear weighting, 
% dcf: Empirical DCF from data, 
% Step size: 0.01

function [k_out_nw, k_out_w, dcf] = kernel_regridding_20170628( k_in, x_in, y_in, kb, w, stepsize, kx_cor, ky_cor)

s_out = size(kx_cor);
s_in = size(k_in);  % First dim: FE; Second dim: Channel 
N_fe = s_in(1); % # of FE points in a line
N_ch = s_in(2); % # of Channels
k_out_nw = zeros(s_out(1), s_out(2), N_ch); % k_out no weighting
k_out_w = zeros(s_out(1), s_out(2), N_ch);  % k_out with linear weighting
dcf = zeros(s_out(1), s_out(2)); % Empirical DCF from data

temp = abs( -s_in(1)/2+0.5:s_in(1)/2)'*ones(1, s_in(2)) ; % simple linear weighting function
%w_0 = repmat(ones( s_in, 1)*temp, [1, 1, N_ch]); 
% size(k_in)
% size(temp)
k_in_w = k_in .* temp;

Diff_k = max([kx_cor(1,2) - kx_cor(1,1), kx_cor(2,1) - kx_cor(1,1)]);   % step size in output k-space
x_k_min = min(kx_cor(:));
x_k_max = max(kx_cor(:));
y_k_min = min(ky_cor(:));
y_k_max = max(ky_cor(:));

% Sampling grid of the kb kernel
% persistent ker_x ker_y
[ker_x, ker_y] = meshgrid( w/2 + [-w/2:stepsize:w/2], w/2 + [-w/2:stepsize:w/2]);
ker_length = length([-w/2:stepsize:w/2]);
% ker_x(1:10, 1:10), ker_y(1:10, 1:10), 
for i = 1:N_fe % loop all points in the line
    x_0 = x_in(i);
    y_0 = y_in(i);
    
%     figure(1), imagesc([ker_x, ker_y]), axis image, colorbar, title('kernel coordinate'), pause
    % grid starting point, find the offset in the kb kernel
    x_offset = mod( (x_k_max - x_0-w/2), Diff_k );  % Starting point of the grid in the kb kernel
    y_offset = mod( (y_k_max - y_0-w/2), Diff_k );
    x_start = floor( (x_k_max - x_0-w/2) / Diff_k ); % Starting grid point
    y_start = floor( (y_k_max - y_0-w/2) / Diff_k );
    x_steps = floor( (w - x_offset)/Diff_k ); % # of grid steps in the kb kernel 
    y_steps = floor( (w - y_offset)/Diff_k );
%     w_temp = zeros(y_steps+1, x_steps+1); % weighting function from kb kernel
    k_temp_nw = zeros( y_steps+1, x_steps+1, N_ch );
    k_temp_w = zeros( y_steps+1, x_steps+1, N_ch );
%     [kx_temp, ky_temp] = meshgrid( x_offset+(0:x_steps)*Diff_k, y_offset+(0:y_steps)*Diff_k ); % coordinate in the kernel
%     kx_temp(1:1, 1:end), ky_temp(1:end, 1:1),pause
%     figure(1), imagesc( [ ker_x, ker_y ] ), colorbar, pause,
%     figure(2), imagesc( [ kx_temp, ky_temp] ), colorbar
%     tic
%     w_temp = interp2( ker_x, ker_y, kb, kx_temp, ky_temp, 'linear'  ); %pause % regridding using linear interpolation
%     w_temp = interp2( ker_x, ker_y, kb, kx_temp, ky_temp, 'nearest'  ); %pause % regridding using linear interpolation
    % nearest neighbor regridding
    ker_xtemp = mod( round((x_offset+(0:x_steps)*Diff_k)/stepsize)-1, ker_length) + 1;
    ker_ytemp = mod( round((y_offset+(0:y_steps)*Diff_k)/stepsize)-1, ker_length) + 1;
    w_temp = kb(ker_ytemp, ker_xtemp);
%     toc
    temp_ker_x = mod(x_start + [0:x_steps] -1, s_out(2))+1; % Regridded position in the output grid
    temp_ker_y = mod(y_start + [0:y_steps] -1, s_out(1))+1; % Regridded position in the output grid
    dcf( temp_ker_y, temp_ker_x ) = dcf( temp_ker_y, temp_ker_x ) + w_temp; % Empirical DCF
    for j = 1:N_ch
        k_temp_nw(:,:,j) = k_temp_nw(:,:,j) + w_temp*k_in(i, j) ;   % Regridding non-weighted k-space data
        k_temp_w(:,:,j) = k_temp_w(:,:,j) + w_temp*k_in_w(i, j) ;     % Regridding weighted k-space data
    end
    k_out_nw( temp_ker_y, temp_ker_x, : ) = k_out_nw( temp_ker_y, temp_ker_x, : ) + k_temp_nw ;
    k_out_w( temp_ker_y, temp_ker_x, : ) = k_out_w( temp_ker_y, temp_ker_x, : ) + k_temp_w ;
end






