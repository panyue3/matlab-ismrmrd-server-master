
%

function psedu_inv_1 = my_pinv(temp2, sigma)

psedu_inv_1 = 0;
s = size(temp2);

if sigma > 0.99999999,
    'Error! sigma must be a real number (0,1)!'
    return
end

if s(1) > s(2)
    c_0 = (temp2'*temp2);
    [V,D]=eig((c_0+(c_0)')/2);
    E = abs(diag(D));
    min_E = min(E);
    E = E/min_E;
    max_E = max(E);
    inv_D = diag(( E./(E.^2 + (sigma*max_E).^2./E.^2 ) )/min_E);
    psedu_inv_1 = V*inv_D*V'*temp2' ;
    %figure(1), semilogy(1:length(E), ( E./(E.^2 + (sigma*max_E).^2./E.^2 ) ), 'o', 1:length(E), ( 1./E ), 'x', 1:length(E), ( E ), 'v'), pause,
else
    return
end








