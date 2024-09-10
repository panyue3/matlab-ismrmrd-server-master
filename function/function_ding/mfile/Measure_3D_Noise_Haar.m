function [ Noise ] = Measure_3D_Noise_Haar( a_0 )
%[ Noise ] = Measure_3D_Noise_Haar( a_0 )
%   a_0: Input 3-D image series
%   Noise: Output 2-D spatial noise std map

%   Based on Donoho 1994 papers, please find one by yourself as the reference.
%   Ding, Yu 2012-10-24, all rights NOT reserved

s_0 = size(a_0);
Noise = zeros(s_0(1), s_0(2));
if length(s_0) ~=3,
    disp('Error!, Input MUST be a 3-D Array!')
    return,
end

a_temp = reshape( a_0, [s_0(1)*s_0(2), s_0(3)] );
swa = zeros( 1, s_0(3) );
swd = zeros( s_0(1)*s_0(2), s_0(3) );

for index_12 = 1:prod(s_0(1:2))
    %size(swt( a_0(index_12,:), 1, 'db1' ))
    [ swa, swd(index_12,:) ] = swt( a_temp(index_12,:), 1, 'db1' );
end

swd_temp = abs(swd);
Noise = median( swd_temp, 2 ) / 0.6745 ;
Noise = reshape( Noise, [s_0(1), s_0(2)] ) ;
%Noise_Var = mean(Noise(:).^2) ,

end

