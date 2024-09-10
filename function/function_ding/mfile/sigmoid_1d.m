
function y = sigmoid_1d( x_length, x_width, x_trans )

% function y = sigmoid_1d( x_length, x_width, x_trans )
% x_length: Total length of the output
% x_width:  Center flat region of the sigmoid function
% x_trans: the transition region width on each side
% 2019-02-11 Ding Yu


x_cen = (x_length+1)/2 ;
x = abs((1:x_length) - x_cen)';

% decay constant for transition width = x_trans
x_t_r = x_trans/log(20)/2; 

y = 1./( exp((x-x_width/2)./x_t_r) + 1 );

