function check_individual_image(fname)
close all hidden
a0 = readin_160_120_file(fname);
i00 = size(a0),
a0 = reshape_128_128_093003(a0,0.0618);
for i=1:i00(3)
    imagesc(a0(:,:,i)), pause(1),
end
