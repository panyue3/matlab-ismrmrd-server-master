% Author: Yu Ding
%Wave front interpolation.
% This is the function to do wave front interpolation. The output is a
% two-D array, they are x-coordinate and y-coordinate of the third order
% interpolation of the wave front. [x,y] = Wave_Front(v,v_min,v_max)
% v must be a one-D array, v_min,v_max are the low and high wave front
% critia, they should be scaled by the maximum v value 0.2, 0.8 or 0.3, 0.7.
% step size 0.1;

%function [x,y] = Wave_Front_jump(v)
function x_r = Wave_Front_jump(v)

[s_1,s_2] = size(v);

if s_2==1;
    v = v';
elseif s_1 == 1;
else
    'Error: One-D array Only',
    return
end

s = length(v);
v_m = max(v); % Find the maximum
L0 = find(v==max(v(1:s-1))); % Find the peak position
a0 = v(1:L0(1)+2);  % This is the array from 1 to first maximum.
L_min_0 = find(a0==min(a0)); % Find the position of minimum in a0.
a0_min = min(a0);

L_m = find(abs( a0-0.5*( v_m(1)+a0_min(1)) ) == min(abs( a0-0.5*( v_m(1)+a0_min(1)) ))); % Only search wave front, start from finding center of wavefront.

%%added by Shivraman. Check
L = L_m-1;
%%%%%%%%%%%%%%
for i = L_m-1:L0(1); % Search start from wavefront center.
L=i;
    if 0.5*(v(i+1)+v(i+2))<v(i), break, end % Find the first local maximum.
end



m = L_min_0(length(L_min_0)); % Starting from the first data as maximum difference
for i= L_min_0(length(L_min_0))+1:L-1 % From minimum position search to maximum position, find the maximum difference.
    if a0(i+1)-a0(i)>a0(m+1) - a0(m)  % To find the maximum jump in the wave front
        m = i;
    end
end

L_min_0;
temp = m:m+1;
for j = 1:4;
    if a0(min(temp))-a0(min(temp)-1) > a0(max(temp)+1)-a0(max(temp))
        temp = min(temp)-1:max(temp);
    else
        temp = min(temp):max(temp)+1;
    end
end

b = a0(temp); % this is the wave front generated from the maximum jump data.
x0 = temp;
p = polyfit(x0,b,3);
x = min(x0):0.1:max(x0);
y_v = polyval(p, x);
y_mean = mean([min(y_v) max(y_v)]);
x_r = find(abs(y_v - y_mean) == min(abs(y_v - y_mean)) );
x_r = min(x0)+(x_r-1)*0.1;
return

L_min = L_min_0; % First set it the global minimum, then try to find a local minimum next.
for i = L_m-1:-1:L_min_0; % Search start from wavefront center.
    if v(i+1)<v(i), L_min=i;break, end % Find the first local minimum.
end

%L_m=L_m, L=L,L_min=L_min,

x0 = L_min+1:L-1;
b = a0(x0); x0=x0;

p = polyfit(x0,b,3);
%p = polyfit(x0,b,1);,

x = 1:0.1:s;    % Step size 0.1
y = polyval(p,x); %size_y=size(y);
y(10*(min([(max(x0)+2),L])):length(x)) =0;  figure(1), plot(x,y,'r--',x0,b,'r*'), % Later than maximum value data points =0;
y(1:find(y(1:10*(L(1)-2))==min(y(1: 10*(L(1)-2))))) = 0; % Earlier than minimum value data points = 0;
L_min = find(abs( y(1:x0(2))-v_min )==min(abs( y(1:x0(2))-v_min )) ); % Find min position, start from 1 to x0(2) region.
L_max = find(abs( y(x0(3):length(y))-v_max )==min(abs( y(x0(3):length(y))-v_max )) ); % Find max position.
y(1:L_min(length(L_min))-1)=0;  figure(2),plot(x,y,'g--',x0,b,'g*'), % Earlier data = 0;
y(L_max+1:length(x)) = 0;  figure(3),plot(x,y,'b--',x0,b,'b*'),set(gca,'ylim',[-0.1 1]) % later than max data = 0;


