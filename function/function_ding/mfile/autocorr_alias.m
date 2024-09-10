% [c_m, c] = autocorr_alias(a_0, acc)
% a_0: 3-D data
% acc: acceleration factor 
% c_m: max aliasing
% c: mean of max 10% aliasing

function [c_m, c, c_all] = autocorr_alias(a_0, acc); 

if ndims(a_0) ~= 3 % a_0 is not 3-D
    'Error! Input is not 3-D Data',
    c = 0;
    return
end

s = size(a_0);
n = 0; c = 0;
a_1 = zeros(s(1),s(2),s(3)-1);
for i=1:s(3)-1,  a_1(:,:,i) = a_0(:,:,i+1) - a_0(:,:,i);  end,
for i=1:s(3)-1,  a_1(:,:,i) = a_1(:,:,i) - mean(mean(a_1(:,:,i)));  end, % Remove the mean
if s(1) > s(2) % second dimension is the phase encoding direction
    n = floor((s(2) - 1)/acc) + 1; % The FOV/acc point
    a_1_ac = ( ifft(abs(fft( a_1, [],2 )).^2,[],2) ); % FFT the phase encoding direction
    for i=1:s(3)-1, a_1_ac(:,:,i) = a_1_ac(:,:,i)./( 0.0000000001+squeeze(a_1_ac(:,1,i))*ones(1,s(2)) ); end,% scale to autocorrelation
    %mean_ac = max(squeeze(mean(a_1_ac,1)),[],2); c = mean_ac(n)/mean_ac(1) ;
    c_m = max( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))) ); % Mean frequency encoding direction, max of all image pairs
    t = sort( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))),'descend' ); c =mean(t(1:max([2,round(0.1*s(3))])));% mean of max 10% 
    c_all = ( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))) );
    %t = sort( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))),'descend' ); c =mean(t( 2 ));% mean of max 10% 
    %c = mean( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))) ); % Mean frequency encoding direction, mean of all image pairs, bad results
    %c = median( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))) ); % Mean frequency encoding direction, median of all image pairs, bad results
else % first dimension is the phase encoding direction
    n = floor((s(1) - 1)/acc) + 1, % The FOV/acc point
    a_1_ac = ( ifft(abs(fft( a_1, [],1 )).^2,[],1) ); % FFT the phase encoding + temporal directions
    for i=1:s(3)-1, a_1_ac(:,:,i) = a_1_ac(:,:,i)./(ones(s(1),1 )*( 0.0000000001 + squeeze(a_1_ac(1,:,i)) )); end,% scale to autocorrelation
    %mean_ac = max(squeeze(mean(a_1_ac,2)),[],2); c = mean_ac(n)/mean_ac(1); % Flip phase encoding direction
    c_m = max( squeeze(sqrt(mean(a_1_ac(n,:,:).^2,2))) ); % Mean frequency encoding direction, max of all image pairs
    t = sort( squeeze(sqrt(mean(a_1_ac(n,:,:).^2,2))),'descend' ); c =mean(t(1:max([2,round(0.1*s(3))])));% mean of max 10% 
    c_all = max( squeeze(sqrt(mean(a_1_ac(:,n,:).^2,1))) );
    %t = sort( squeeze(sqrt(mean(a_1_ac(n,:,:).^2,2))),'descend' ); c =mean(t( 2 ));% mean of max 10% 
    %c = mean( squeeze(sqrt(mean(a_1_ac(n,:,:).^2,2))) ); % Mean frequency encoding direction, mean of all image pairs, bad results
    %c = median( squeeze(sqrt(mean(a_1_ac(n,:,:).^2,2))) ); % Mean frequency encoding direction, median of all image pairs, bad results
    %'first'
end



