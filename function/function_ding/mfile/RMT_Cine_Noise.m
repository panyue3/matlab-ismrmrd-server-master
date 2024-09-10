% Measure the noise of cine images automatically
% [a_n, p_value] = RMT_Cine_Noise(a_0)
% a_0: input cine images
% a_n: noise only eigenimages,
% p: RMT filtting p-value



function [a_n, p_value, Cutoff ] = RMT_Cine_Noise(a_0)

a_n = 0;
p_value = 0;

s = size(a_0);
if length(s) ~=3
    'Error! The input must be a 3-D data set!',
    return
elseif s(3) < 10
    'Error! Not enough images (must be > 10)!',
    return
end

[a_I, V, D] = KL_Eigenimage( a_0 ); E_0 = diag(D);
for i=1:9, x(i) = E_0(i+1)/E_0(i); end, % find the eigenvalue relative increment
n_0 = find(x==max(x(1:5)));
n_1 = 0;
% find if there is some near degenerate modes
if (x(n_0)-1)> 32*(mean(x([(n_0+1):(n_0+3)]))-1), n_1 = n_0; end, 

[Cutoff, Var_0, ks, beta, p_value, H] = KS_Cutoff_2Steps(E_0(1+n_1:end), s(1)*s(2) ); 

a_n = a_I(:,:,1+n_1:Cutoff);
%Mean_N = mean(E_0(1+n_1:Cutoff));
%figure(1), semilogy(E_0, '*')
