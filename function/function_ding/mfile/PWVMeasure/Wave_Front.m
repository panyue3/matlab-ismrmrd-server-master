% Wave front interpolation.
% This is the function to do wave front interpolation. The output is a
% two-D array, they are x-coordinate and y-coordinate of the third order
% interpolation of the wave front. [x,y] = Wave_Front(v,v_min,v_max)
% v must be a one-D array, v_min,v_max are the low and high wave front
% critia, they should be scaled by the maximum v value 0.2, 0.8 or 0.3, 0.7.
% step size 0.1;

function [x,y] = Wave_Front(v,v_min,v_max)

s = length(v);
v_max = max(v);
L0 = find(v==max(v));
a0 = v(1:L0(1));
L_m = find(abs( a0-0.5*v_max(1) ) == min(abs( a0-0.5*v_max(1) ))); % Only search wave front

for i = max(1,L_m-1):L0(1)+2; 
    if v(i+1)<v(i), L=i;break, end % Find the first local maximum.
end
a = v(1:L0(1))/v(L);

if a(L_m(1))>=0.5,
    x0 = L_m(1)-2:L_m(1)+2 ; 
else
    x0 = L_m(1)-1:L_m(1)+3;
end
b(1:5) = a(x0); ,x0=x0;

p = polyfit(x0,b,3);
%p = polyfit(x0,b,1);,

x = 1:0.1:s;    % Step size 0.1
y = polyval(p,x);
y(10*(min([(max(x0)+2),L])):length(x)) =0; %plot(x,y,'--',x0,b,'*')% Later than maximum value data points =0;
y(1:find(y(1:10*(L(1)-2))==min(y(1: 10*(L(1)-2))))) = 0; % Earlier than minimum value data points = 0;
L_min = find(abs( y-v_min )==min(abs( y-v_min )) ); % Find min position.
L_max = find(abs( y-v_max )==min(abs( y-v_max )) ); % Find max position.
y(1:L_min(length(L_min))-1)=0;  % Earlier data = 0;
y(L_max+1:length(x)) = 0; % later than max data = 0;


