
% Yu Ding 2024-08-19

function a_i = transport_interp2(a_1, a_2)

a_i = (a_1+a_2)/2;
%addpath(genpath('R:\CMRCT Lab Team\YuDing\Matlab\Code\MOCO'))
s_0 = size(a_1);

[y,x] = meshgrid(-s_0(2)/2:s_0(2)/2-1, -s_0(1)/2:s_0(1)/2-1);

[~, dy, dx, dyInv, dxInv] = PerformMoCo(a_1, a_2, 1*[32 32 48], 12);

Fx = x + dx;
Fy = y + dy;
Bx = x + dxInv;
By = y + dyInv;

temp_1 = interp2( y, x, a_2, (Fy+y)/2, (Fx+x)/2, 'spline');
temp_2 = interp2( y, x, a_1, (By+y)/2, (Bx+x)/2, 'spline');

a_i = (temp_1 + temp_2)/2;



