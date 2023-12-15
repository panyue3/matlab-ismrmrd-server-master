function [data_rmdrift, trans_drift] = remove_drift(data)

drift = nan(size(data));
for jj = 1:size(data,2)
    p(:,jj) = polyfit((1:size(data,1))', data(:,jj),1);
    drift(:,jj) = polyval(p(:,jj),1:size(data,1));
end

[V_drift, ~] = eig(drift'*drift);
I = eye(size(data,2));
I(end-1:end,end-1:end) = 0;
trans_drift = (V_drift * I)/V_drift;
data_rmdrift = data * trans_drift;

end