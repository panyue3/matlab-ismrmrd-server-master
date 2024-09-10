% Regridding using pre-calculated kernel function 
% kernel_2D_regridding(x_0, y_0, N_0, kb)
% x_in: input x-axis
% y_in: input y-axis
% N_0: output matrix size
% kb: 2D regridding kernel
% k_out: output k-space matrix, size N_0 x N_0
% Step size: 0.01

function k_out = kernel_3D_regridding(x_in, y_in, N_0, kb)

k_out = zeros(N_0, N_0);
if mod(N_0,2) == 1
    disp('Error! N_0 MUST be EVEN!')
    return
elseif 100*N_0 > size(kb, 1)
    disp('Error! N_0 MUST be smaller than kb/100!')
    return
end

s_0 = size( kb );
ker_center_x = (s_0(1)+1)/2;
ker_center_y = (s_0(2)+1)/2;
%ker_center = find(kb == max(kb));
x_res = round((x_in - floor(x_in))*100) ;
y_res = round((y_in - floor(y_in))*100) ;
% delta_x = ker_center - x_res;
% delta_y = ker_center - y_res;

x_coor = ker_center_x + [(-N_0/2+1)*100:100:N_0/2*100] - x_res;
y_coor = ker_center_y + [(-N_0/2+1)*100:100:N_0/2*100] - y_res;

k_out = kb(x_coor, y_coor, :);





