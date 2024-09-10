% This is a new version of reshape, want to avoid the periodic boundary 
% effect by reshape it to 160x160 then reshape it to 128x128
% No Gaussian filter applied

function a0 = reshape_128_128_111803(a, lp)

% if min(a(:))==0, a=a+1; end
asize = size(a);
a00 = sum(a,3);
amean = mean(a(:));

% find the min value of the image
[n_hist,x_hist]=hist(a00(:));
amin = x_hist(1)/asize(3);
% Initialize two matrix, the eventually amin will remain on the boundary
b0 = ones(160,160,asize(3))*amin;
a0 = ones(128,128,asize(3))*amin;

b0(:,21:140,:)=a;     clear a,
b00 = sum(b0,3);
alp = lpfilter(b00,lp); % figure(2), imagesc(alp)
b00 = b00./alp;
ay = sum(b00,2);

% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
for i=1:33, ty(i) = sum(ay(i:i+127)); end
y0 = find(max(ty)==ty); % imagesc(a00),pause(10)
% Low pass filter each individual image
for i=1:asize(3)
    % Make the illumination the same
    b0(:,:,i) = b0(:,:,i)./alp;
    % Give the output matrix (1:160,5:124) value 
    a0(:,:,i) = min(min(b0(:,:,i)));
    a0(:,5:124,i)=b0(y0:y0+127,21:140,i);
end

% Smooth the boundary using exp function
for i=2:4
    a0(1:128,i,:) = a0(1:128,i,:) + 0.5^(5-i)*( a0(1:128,5,:) - a0(1:128,1,:) ) ;  
    a0(1:128,129-i,:) = a0(1:128,129-i,:) + 0.5^(5-i)*( a0(1:128,124,:) - a0(1:128,128,:) ) ; 
end
a0 = a0*(amean/mean(a0(:)));