
% Cartesian Pattern weight function 
% d_1 = Cart_Weight_Func_20180725(kdata)
% [N_fe, N_pe, N_ch, N_fr] = size(kdata);

function d_1 = Cart_Weight_Func_20180725(kdata)

[N_fe, N_pe, N_ch, N_fr] = size(kdata);
temp = squeeze((sum(abs(kdata),3))) > 0;
temp_mask_0 = squeeze(temp(1, :, :)); 


d_1 = zeros( N_fe, N_pe, N_fr );
for i=1:N_fr
    d = [];
    x = find(temp_mask_0(:,i));
    y(1) = x(end)-N_pe;
    y(2:(length(x)+1)) = x;
    y((length(x)+2)) = x(1) + N_pe;
    t = diff(y);
    for j = 1:length(x)
        d_0(j) = mean(t([j,j+1])); % mean of adjacent interval
    end
    d = d_0 / mean(d_0); % Scale weighting function
    for j = 1:length(x)
        d_1( :, x(j), i) = d(j);
    end
    %     d
end





