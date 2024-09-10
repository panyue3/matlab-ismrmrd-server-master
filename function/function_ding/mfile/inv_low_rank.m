
% function psedu_inv_1 = inv_reg(temp2, sigma)

%function psedu_inv_1 = inv_reg(c_0, sigma)
function psedu_inv_1 = inv_low_rank(c_0, varargin)

psedu_inv_1 = 0;
s = size(c_0);

if nargin == 2
    sigma = varargin{1};
else
    sigma = s(1)/2; % 1/10000 of the maximum singular value
end

if sigma > s(1),
    'Error! sigma must be a real number < dim(c_0)!'
    return
end
if s(1) ~=s(2)
    'Error!, c_0 must be a square matrix'
    return
end
%tic
if s(1) < 16000
    [V,D]=eig(single(c_0+(c_0)')/2); %'a', toc, tic,
    E = abs(diag(D));
    E = E( end-sigma+1 : end); E_L = length(E);
    inv_D = diag(1./E);
    %figure(1), semilogy(1:length(E), ( E./(E.^2 + (sigma*max_E).^2./E.^2 ) ), 'o', 1:length(E), ( 1./E ), 'x', 1:length(E), ( E ), 'v'), pause,
else
    opts.disp=0; opts.tol=0.0001; opts.issym=1; 
    [V, D] = eigs(double(c_0), 200, 'LM', opts);
    %D = abs(D); inv_D = (D>sigma*max(D(:))).*diag(1./diag(D));
    E = abs(diag(D));
    E = E(find(E>sigma*E(end))); E_L = length(E);
    inv_D = diag(1./E);
end

psedu_inv_1 = V(:,end-E_L+1:end)*inv_D*V(:,end-E_L+1:end)' ;
%'c', toc,




