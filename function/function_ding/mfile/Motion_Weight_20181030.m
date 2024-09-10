
% function w_spokes = Motion_Weight( Res_Signal )
% Res_Signal: the motion curve after removing the background
% w_spokes: weighting for each spokes
% 
% Ding Yu 2018-10-30
%
% Add one more input to change the threshold, 
% w_spokes = Motion_Weight_20181030( Res_Signal, E_c )
% 
% Ding Yu 2019-07-27 
% 

function w_spokes = Motion_Weight_20181030( Res_Signal, E_c )

if nargin == 1
    E_c = 0.35;
end
[x, I] = sort(Res_Signal);
L_x = length(x);

x = 0:1/(L_x-1):1; 

T = 12;

w_spokes(I) = 1./(1 + exp(-(x-E_c)*T));

% figure(1), plot(Res_Signal)
% figure(2), plot(y)
% x = 0:0.001:1; T = 12;
% w_spokes = 1./(1 + exp(-(x-E_c)*T));
% figure(1), plot(x, w_spokes, x, 2*w_spokes.*w_spokes), grid on 
% figure(2), plot(x, w_spokes, x, w_spokes.*w_spokes), grid on 

% w_spokes_1 = 1./(1 + exp(-(x-0.35)*T));
% w_spokes_2 = 1./(1 + exp(-(x-0.50)*T));
% w_spokes_3 = 1./(1 + exp(-(x-0.65)*T));
% 
% figure(1), plot( x, w_spokes_1,  x, w_spokes_2,  x, w_spokes_3  )

