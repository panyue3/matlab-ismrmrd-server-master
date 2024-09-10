%% Translated from Amir's code in IDL
%% Xiangyu Yang
%% 2011.03.15

function new_array = expandArray(array, dat, index, isize, ioffset)
    
    % the xvarialbe name (ndims) in the original IDL code is a function
    % name in Matlab.
    n_dims = size(array);
    if ndims(array) > 1
        n_dim2 = n_dims(2)+1;
    else
        n_dim2 = 2;
    end
    dummyc = complex(0., 0.);
    new_array = repmat(dummyc, [index(isize+1)/8], n_dim2); 
    new_array(:, 1:n_dim2-1) = array(:, :);
    fseek(dat, index(ioffset+1), 'bof');

    tmp = fread(dat, [2, index(isize+1)/8], 'float');
    tmp = complex(tmp(1, :), tmp(2, :));
    tmp = tmp.';
    new_array(:, n_dim2) = tmp(:);
    
end