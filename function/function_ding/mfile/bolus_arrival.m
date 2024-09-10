
% 2018-11-09
% find the bouls arrival time
% function output = bolus_arrival(input)
% input.kc: k-space center ()
% input.medfiltwidth: width of 1-D median filter  
% output.bolus_arrive_time: 1x2 array, linear fitting & 5% threshold 
% output.original_curve: 2 x N Array 
% output.filtered_curve: 2 x N Array  
% output.fit_line: 2 x N Array  

function output = bolus_arrival(input)

medfiltwidth = input.medfiltwidth;
kc = input.kc;

N_offset = round((medfiltwidth+3)/2);
T_e = squeeze(sqrt(sum(sum(abs(kc).^2, 3),1)));
T_e_f = medfilt1(T_e, 55);
N = N_offset+1 : length(T_e)-N_offset;

% figure(1), plot( N, T_e_f(N), 'o' ), hold on

Mid_I = (max(T_e_f(N)) - min(T_e_f(N)))*0.5+ min(T_e_f(N)); 
temp = find(abs( T_e_f(N)-Mid_I ) == min(abs( T_e_f(N)-Mid_I )));
Mid_N = temp(1);

% Fitting data:
% data = T_e_f(28+(1:Mid_N)); 
data = T_e_f( N );
% data(end)

% Estimate base line
Min_N = N_offset + find( data == min(data) );
Range_b = [ max([1, Min_N(1)-30 ]): Min_N(1)+30 ];
I_baseline = median( T_e(Range_b) ) ;

% Estimate height
Max_N = N_offset + find( data == max(data) );
Range_h = [ Max_N(1)-30 : min([ length(T_e), Max_N(1)+30 ]) ];
I_height = median( T_e(Range_h) ) - I_baseline;

% Estimate slope
x(1:41, 1) = N_offset + Mid_N + [-20:20];
x(1:41, 2) = 1;
y(1:41, 1) = T_e_f( N_offset + (Mid_N-20:Mid_N+20) );
b = inv(x'*x)*(x'*y);
T_I = 4*b(1)/I_height ; 

t(1:length(N), 1) = 1:length(N);
t(1:length(N), 2) = 1;
fit_Line = t*b;
% fit_Curve = I_baseline + I_height./( 1 + exp( (-N+Mid_N+N_offset)*T_I ) );

% Linear fit prediction
output.bolus_arrive_time = find(abs(fit_Line-I_baseline)== min(abs(fit_Line-I_baseline)));  
output.original_curve = [T_e; 1:length(T_e)];
% size(T_e_f), size(N)
output.filtered_curve = [T_e_f(N); N];
output.fit_line = [fit_Line'; 1:length(N)] ;
output.baseline = I_baseline ;
output.midpointtime = Mid_N + N_offset;
output.I_height = I_height;

Thresh_I = I_height*0.05 + I_baseline;
for i=Min_N : Min_N + Mid_N
    if T_e_f(i) > Thresh_I, 
        output.bolus_arrive_time(2) = i;
        break
    end
end

return
