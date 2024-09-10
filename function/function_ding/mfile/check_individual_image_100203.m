addpath Z:\ding\matlab\100203
close all
a0 = readin_160_120_file('4000_400_16_0_32');
i00 = size(a0),
a0 = reshape_128_128(a0,0.0618);
for i=1:6
    imagesc(a0(:,:,i)), pause(1),
end
