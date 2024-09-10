
% function y = sigmoid_step_func( x, x_cen, x_trans )
% x_cen: Center of the transition region
% x_trans: the transition region width 
% 2019-04-26 Ding Yu



function y = sigmoid_step_func( x, x_cen, x_trans )

x_t_r = x_trans/log(20)/2; 

y = 1./( exp((x-x_cen)./x_t_r) + 1 );










