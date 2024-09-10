% function [a_1, a_m, a_index] = sliding_window(a_0, option)
% a_1: sliding window 3-D data array
% a_m: mean value 2-D arrray
% x_start = option.x_start;
% y_start = option.y_start;
% x_end = option.x_end;
% y_end = option.y_end;
% x_step = option.x_step;
% y_step = option.y_step;
% x_win = option.x_win;
% y_win = option.y_win;

function [a_1, a_m, a_std, a_index] = sliding_window(a_0, option)

x_start = option.x_start;
y_start = option.y_start;
x_end = option.x_end;
y_end = option.y_end;
x_step = option.x_step;
y_step = option.y_step;
x_win = option.x_win;
y_win = option.y_win;

s_0 = size(a_0);
L_x = length( x_start:x_step:x_end );
L_y = length( y_start:y_step:y_end );

a_1 = zeros(x_win, y_win, L_y*L_x);
a_m = zeros(1, L_y*L_x);
a_std = zeros(1, L_y*L_x);
a_index = zeros(2, L_y*L_x);
Counter = 0;
% for i=x_start:x_step:x_end
%     x_index = mod( (i:i+x_win-1)-1, s_0(1) ) + 1;
%     for j = y_start:y_step:y_end
%         Counter = Counter + 1;
%         y_index = mod( (j:j+y_win-1)-1, s_0(2) ) + 1;
for j = y_start:y_step:y_end
    y_index = mod( (j:j+y_win-1)-1, s_0(2) ) + 1;
    for i=x_start:x_step:x_end
        x_index = mod( (i:i+x_win-1)-1, s_0(1) ) + 1;
        Counter = Counter + 1;
        temp = a_0( x_index, y_index );
        temp_m = mean(temp(:));
        a_1(:,:,Counter) = temp;
        a_std(:,Counter) = std(temp(:));
        a_m(:,Counter) = temp_m; 
        a_index(:, Counter) = [i;j];
    end
end







