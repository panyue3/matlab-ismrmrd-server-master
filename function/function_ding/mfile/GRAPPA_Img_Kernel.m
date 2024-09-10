
% calculate GRAPPA image space kernel

function image_kernel = GRAPPA_Img_Kernel(coefficient, kspace_size, header, varargin)

s_0 = kspace_size;
s_1 = size(coefficient);
N_fe = s_0(1);
N_pe = s_0(2);
N_ch = s_0(3);
Ker_pe = header.KernelSize(1); % Assume this is an odd number
Ker_fe = header.KernelSize(2);  % Assume this is an even number
image_kernel = zeros(N_fe, N_pe, N_ch, N_ch);

if length(kspace_size) ~= 3
    disp('kspace_size is not a 3-element 1-D array!')
    return
end

if s_1(1)~= prod(header.KernelSize)*N_ch
    disp('Kernel size and Coefficent size does not match!')
    return
elseif s_1(2) ~= length(header.OutPattern)*N_ch
    disp('Output size and Coefficent size does not match!')
    return
end

d_pe = diff(header.KernelPattern);
if d_pe(1) == length(header.OutPattern)+1
    Acc = d_pe(1);
else
    disp('Acceleration factor and out pattern does not match!')
    return
end

N_sets = length(header.OutPattern),
Ker_blocs = zeros( Ker_fe, Acc*Ker_pe, N_ch, N_ch); 

for i=1:N_sets
    Temp_C = reshape(coefficient( :, i:N_sets:end), [Ker_fe, Ker_pe, N_ch, N_ch ]);
    %Ker_blocs(:, i:Acc:end, :, :) = Temp_C;
   %Ker_blocs(:, (Acc-i+1):Acc:end, :, :) = Temp_C(end:-1:1, end:-1:1, :,:);
   Ker_blocs(:, (Acc-i+1):Acc:end, :, :) = Temp_C;
end

% Add the unity in the middle of the kernel 2023-09-21
for i=1:N_ch
    Ker_blocs((Ker_fe+1)/2, (Acc*Ker_pe)/2+1, i, i) = 1;
end


x_cen = N_fe/2 + 1;
y_cen = round((N_pe+1)/2);
Ker_x_w =  (Ker_fe-1)/2;
Ker_y_w =  (Acc*Ker_pe)/2-1;

k_temp = image_kernel;
k_temp( x_cen+[-Ker_x_w : Ker_x_w], y_cen+[-Ker_y_w:Ker_y_w], :, : ) = (Ker_blocs(end:-1:1, end:-1:2,:,:));
%k_temp( x_cen+[-Ker_x_w : Ker_x_w], y_cen+[-Ker_y_w:Ker_y_w], :, : ) = (Ker_blocs(:,2:end,:,:));

image_kernel = ifft2c(k_temp);

return


