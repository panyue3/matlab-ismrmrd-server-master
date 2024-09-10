% This is the Least Square Fitting in Fixed slope. The data was fit by a
% y =  a*x + b; where a is fixed, find the best value of b.
% b = LSF_a(x,y,a), x and y are 1-D array.

function b = LSF_a(x,y,a)

x_c = mean(x);
y_c = mean(y);
a_0 =polyfit(x,y,1);

b_lim = max(std(y),abs((a_0(1)*x_c - a*x_c)));
b_step = b_lim/5000 ;
b_1 = a_0(2) - b_lim*2 : b_step : a_0(2) + b_lim*2;
%size(b_1)
target = sum((y'*ones(size(b_1)) - (a*x'*ones(size(b_1)) + ones(size(x'))*b_1)).^2);
%figure(2), plot(target);
min_t = find(target == min(target(:))); % pause
b = a_0(2) - b_lim*2 + round(median( min_t ))*b_step;
%pause,