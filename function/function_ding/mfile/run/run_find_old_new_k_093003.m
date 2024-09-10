addpath Z:\ding\matlab\090703

for A4=3500:100:4500,
    n4 = A4/100;
    for A5 = 500:10:600,
        n5 = A5/10;
        fname = sprintf('%i_%i_%i_%i_%i',A4,A5,16,0,32),
        a0 = readin_160_120_file(fname);
        i00 = size(a0);
        a0 = reshape_128_128(a0,0.0618);
        for i=1:i00(3)
            k0(i) = find_matrix_k(a0(:,:,i));
        end
        k_old(n4,n5) = median(k0);
    end
end

rmpath Z:\ding\matlab\090703
addpath Z:\ding\matlab\092503

for A4=3500:100:4500,
    n4 = A4/100;
    for A5 = 500:10:600,
        n5 = A5/10;
        fname = sprintf('%i_%i_%i_%i_%i',A4,A5,16,0,32),
        a0 = readin_160_120_file(fname);
        i00 = size(a0);
        a0 = reshape_128_128(a0,0.0618);
        for i=1:i00(3)
            k0(i) = find_matrix_k(a0(:,:,i));
        end
        k_new(n4,n5) = median(k0);
    end
end