% 2018-08-16 L2 weighting mask for 

% function mask_2 = L2_Mask_new( N_spokes, N_k, Ratio_0)
% 
% switch nargin
%     case 2
%         Ratio_0 = 4;
% end

function mask_2 = L2_Mask_new( N_spokes, N_k, Ratio_0)

switch nargin
    case 2
        Ratio_0 = 4;
end

if length(N_k) == 1
	mask_2 = ones(N_k, N_k);
    N_max = N_k;
    N_k = [N_k, N_k];
elseif length(N_k) == 2
	mask_2 = ones(N_k(1), N_k(2));
	N_max = max(N_k);
end

%[x, y] = meshgrid( -N_k/2:N_k/2-1, -N_k/2:N_k/2-1 );
[x, y] = meshgrid( linspace(-N_max/2, N_max/2-1, N_k(2)), linspace(-N_max/2, N_max/2-1, N_k(1)) );

%for i = 1:N_k
%    for j = 1:N_k
%        x(i,j) = -N_k/2-1 + j;
%        y(i,j) = -N_k/2-1 + i;
%    end
%end

r_0 = sqrt(x.^2 + y.^2); %figure, imagesc(r_0), axis image

Ratio_max = max([N_max/2/N_spokes*pi/Ratio_0, 1]);

r_1 = N_spokes/pi;

for i = 1:length(r_0(:))
    if ( r_0(i) > r_1 )&&( r_0(i) < (N_max/2-1) )
        mask_2(i) = 1 + (Ratio_max - 1)/(N_max/2-r_1)*(r_0(i)-r_1);
    elseif r_0(i) >= (N_max/2-1)
        mask_2(i) = 0;
    end
end
 

