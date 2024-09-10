% Unwrap the blood flow images
% a_1 = my_unwrapdirection(a_0, mask, d)
% a_0 3-D flow data set [0 4095]
% mask: mask for the blood vessel
% d > 0,V too high aliasing
% d <= 0,V too low aliasing

function a_u = my_unwrap_direction(a_0, mask, d)

s = size(a_0);
N = s(3);
if length(s) ~=3,
    'Error: Input array is not a 3-D array!'
    a_u = a_0;
    return
end
a_u = a_0;
for i=1:N % loop the third dimension, time
    S = sum(sum(mask(:,:,i)));
    temp = a_0(:,:,i) ; 
    V = temp( find(mask(:,:,i)==1 ) );
    V_m = median(V(:)); % Mediann velocity
    if d > 0 % 
        V(find(V<512)) = V(find(V<512)) + 4096; % V too high aliasing
    else
        V(find(V>3584)) = V(find(V>3584)) - 4096; % V too low aliasing
    end
    temp( find(mask(:,:,i)==1 ) ) = V; % 
    a_u(:,:,i) = temp ;
end
    
    
    