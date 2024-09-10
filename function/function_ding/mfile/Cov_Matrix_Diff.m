% Diff of cov matrices
% function x = Cov_Matrix_Diff(A, B)

function x = Cov_Matrix_Diff(A, B)

sa = size(A); sb = size(B);
size_b = [sa==sb];
if prod(double(size_b(:)))
    x = norm( log(eig(A, B)) );
    return
else
    'Matrix A & B must be the same size'
    return
end

