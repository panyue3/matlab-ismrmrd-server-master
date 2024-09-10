% function mask_2 = L2_Mask( N_spokes, N_k, Ratio_0)
% 
% switch nargin
%     case 2
%         Ratio_0 = 4;
% end

function mask_2 = L2_Mask( N_spokes, N_k, Ratio_0)

switch nargin
    case 2
        Ratio_0 = 4;
end

mask_2 = ones(N_k, N_k);
%[x, y] = meshgrid( -N_k/2:N_k/2-1, -N_k/2:N_k/2-1 );

for i = 1:N_k
    for j = 1:N_k
        x(i,j) = -N_k/2-1 + j;
        y(i,j) = -N_k/2-1 + i;
    end
end

r_0 = sqrt(x.^2 + y.^2); %figure, imagesc(r_0), axis image

Ratio_max = max([N_k/2/N_spokes*pi/Ratio_0, 1]);

r_1 = N_spokes/pi;

for i = 1:length(r_0(:))
    if ( r_0(i) > r_1 )&( r_0(i) < (N_k/2-1) )
        mask_2(i) = 1 + (Ratio_max - 1)/(N_k/2-r_1)*(r_0(i)-r_1);
    elseif r_0(i) >= (N_k/2-1)
        mask_2(i) = 0;
    end
end
 

