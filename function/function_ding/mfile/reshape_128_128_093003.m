% Reshape the 160x120 images to 128x128 size
% Make the illumination the same
% Window it (Gaussian)
% a0 = reshape_128_128(a, lp) a is the input 160x120xN array, lp is the
% lpfilter cutoff threshhold

function a0 = reshape_128_128(a, lp)

asize = size(a);
a00 = sum(a,3);
alp = lpfilter(a00,lp);
a00 = a00./alp;
ay = sum(a00,2);
 
% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
for i=1:33, ty(i) = sum(ay(i:i+127)); end
y0 = find(max(ty)==ty); % imagesc(a00),pause(10)
% Low pass filter each individual image
for i=1:asize(3)
    a(y0:y0+127,:,i)=a(y0:y0+127,:,i)./alp(y0:y0+127,:);
end
% Reshape them, use the 
a01 = sum(a(y0:y0+127,:,:),3);
[n_hist,x_hist]=hist(a01(:));
amin = x_hist(1)/asize(3); % min(a01(:))/asize(3),pause(10)
a0 = amin*ones(128,128);
a0(1:128,5:124,1:asize(3))=a(y0:127+y0,:,:); % figure(1), imagesc(a0(:,:,1))
% Smooth the boundary using exp function
for i=2:4
    a0(1:128,i,:) = a0(1:128,i,:) + 0.5^(5-i)*( a0(1:128,5,:) - a0(1:128,1,:) ) ;  
    a0(1:128,129-i,:) = a0(1:128,129-i,:) + 0.5^(5-i)*( a0(1:128,124,:) - a0(1:128,128,:) ) ; 
end
% figure(1), imagesc(a0(:,:,1)); pause(1)
[x,y] = meshgrid(1:128,1:128);
mask = exp(-((x-65).^2+(y-65).^2)./6000);

a=0;
for i=1:asize(3)
    a(1:128,1:128) = a0(1:128,1:128,i); % figure(1),imagesc(a)
    a  = bpfilter(a,0.618,0.0618);	% figure(2), imagesc(a), pause(10) 
    a0(1:128,1:128,i) = a(1:128,1:128) ;% if i==5,figure(10),imagesc(a), end
    a0(:,:,i) = a0(:,:,i).*mask;
    a0(:,:,i) = a0(:,:,i) - mean(mean(mean(a0(:,:,i))));
end

%close all hidden
%for i=1:asize(3),imagesc(a0(:,:,1)), axis image, pause(1), end
%bmedian = (median(alp(6,1:118))+median(alp(133,1:118)))/2 ;

