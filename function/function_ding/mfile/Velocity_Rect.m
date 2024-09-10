% rectify the velocity that has aliasing.
% a_r = Velocity_Rect(a_0, V_min, V_max);
% a_0 is a phase-contrast image with [0 4095]
% V_min < 0, V_max >0, -V_min+V_max=2*Venc;
% 

function a_r = Velocity_Rect(a_0, V_min, V_max);

Venc = ( -V_min + V_max)/2; 
Shift = ( V_min + V_max)/( -V_min + V_max)*2048 ; 

if Shift > 0 % max velocity > venc
    a_0(find( a_0 < Shift)) = a_0(find( a_0 < Shift)) + 4095; % low negative v is high positive velocity
elseif Shift < 0 % min velocity < -venc
    a_0(find( a_0 > (Shift+4095) )) = a_0(find( m > (Shift+4095) )) - 4095; % high positve v is low negative velocity
end
a_r = a_0;
