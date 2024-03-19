
function [b_aligned, bp_x, bp_y] = Align_Patch(b_0, p_x, p_y) 
% function [b_aligned, bp_x, bp_y] = Align_Patch(b_0, p_x, p_y)
% b_0: 3-D image data
% p_x: range in first dimension
% p_y: range in second dimension
% b_aligned: aligned 3-D patches
% bp_x: best patch position x (first dimension)
% bp_y: best patch position y (second dimension)

%tic
% Search region size:
N_s = 16; % [-N_s:N_s], length = 2*N_s + 1;

% Patch Size:
L_x = length(p_x);
L_y = length(p_y);
step_x = [-N_s:N_s];
step_y = [-N_s:N_s];

% make sure p_x, p_y are row vectors
if iscolumn(p_x), p_x = p_x'; end
if iscolumn(p_y), p_y = p_y'; end

s_0 = size(b_0);
bp_x = zeros( L_x, s_0(3));
bp_y = zeros( L_y, s_0(3));
b_aligned = zeros(length(p_x), length(p_y), s_0(3));

p_x = mod(p_x - 1, s_0(1)) + 1;
p_y = mod(p_y - 1, s_0(2)) + 1;

mean_patch = mean( b_0(p_x, p_y, :), 3 );
mean_patch = (mean_patch - mean(mean_patch(:)))/std(mean_patch(:));

% search area:
s_x = mod([(-N_s:-1)+p_x(1), p_x, p_x(end)+(1:N_s)]-1, s_0(1))+1;
s_y = mod([(-N_s:-1)+p_y(1), p_y, p_y(end)+(1:N_s)]-1, s_0(2))+1;
b_s = b_0(s_x, s_y, :);
s_b = size(b_s);
b_tot = reshape(b_s, [s_b(1), s_b(2)*s_b(3)]);

% search for best match
temp_1 = abs(normxcorr2( mean_patch, b_tot));
s_t = size(temp_1);
for i=1:s_b(3)
    % disp(i)
    [L_y:(s_t(2)-L_y+1)] + (i-1)*s_b(2);
    temp_s = temp_1(L_x:s_b(1), [L_y:s_b(2)] + (i-1)*s_b(2));
    % disp([L_x,(s_b(1)-L_x+1)])
    % disp([[L_y:(s_b(2)-L_y+1)] + (i-1)*s_t(2)])
    [I, J] = find(temp_s == max(temp_s(:)));  
    % max(temp_s(:));
    % disp([I, J]);
    bp_x(:, i) = mod(p_x + step_x(I(1)) - 1, s_0(1)) + 1;
    bp_y(:, i) = mod(p_y + step_y(J(1)) - 1, s_0(2)) + 1;
    a_temp = b_0(:, :, i);
    b_aligned(:,:,i) = a_temp(bp_x(:, i), bp_y(:, i));
end






% % Alignment of Patches
% for i=1:s_0(3) % Loop frames
%     a_temp = b_0(:, :, i);
%     ab_corr = zeros(length(step_x),length(step_y));
%     
%     for sl_i = 1:length(step_x)
%         a_x = mod(p_x + step_x(sl_i) - 1, s_0(1)) + 1;
%         
%         for sl_j = 1:length(step_y)
%             
%             a_y = mod(p_y + step_y(sl_j) - 1, s_0(2)) + 1;
%             p_temp = a_temp(a_x, a_y);
%             p_temp = (p_temp - mean(p_temp(:)))/std(p_temp(:));
%             ab_corr(sl_i, sl_j) = abs(sum(p_temp(:).*mean_patch(:)));
%         end
%     end
%     disp(max(ab_corr(:)));
%     [I, J] = find(ab_corr == max(ab_corr(:)));  %disp([isempty(I), 100, I, 100, J, 100, step_x(I), 100, step_x(J), 100]), 
%     if isempty(I), I = 10; J = 10; end
%     bp_x(:, i) = mod(p_x + step_x(I(1)) - 1, s_0(1)) + 1;
%     bp_y(:, i) = mod(p_y + step_y(J(1)) - 1, s_0(2)) + 1;
%     b_aligned(:,:,i) = a_temp(bp_x(:, i), bp_y(:, i));
%     %b_mask(mod(p_x + step_x(I) - 1, s_0(1)) + 1, mod(p_y + step_y(J) - 1, s_0(2)) + 1, 1) = 1;
% end









