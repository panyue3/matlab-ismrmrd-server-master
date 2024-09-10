% To get the Noise in the ROI after different KLT cutoffs

function noise = Noise_ROI_Diff_KLT_Cutoff(a, mask, r)

% just write out the my_KL_reshape function directly
s = size(a); 
N = s(3); 
b = (reshape(a, [s(1)*s(2),s(3)] )); clear a 
t_mean = mean(b,1); 
b_mean = ones(s(1)*s(2),1)*t_mean; 
b = b - b_mean; %clear b_mean 
b_std = std(b,0,1); 
A = (b'*b)/(s(1)*s(2)); 
[V,D] = (eig(A));  
V_t = V'; 
 
for i=1:length(r) 
    V_0 = V;
    V_0(:,1:round(N*(1-r(i)))) = 0;
    V_in = (V_0*V_t);
    a_r = (reshape(b*V_in' + b_mean, [s(1),s(2),s(3)] ) ) ;% clear b
    for j=1:s(3)
        t = a_r(:,:,j);
        std_temp(j) = std(t( find(mask==1) ));
        t = 0;
    end
    %noise(i) = mean(std_temp);
    noise(i) = sqrt(mean(std_temp.^2)); % rms version
    std_temp = 0; % clock
end









