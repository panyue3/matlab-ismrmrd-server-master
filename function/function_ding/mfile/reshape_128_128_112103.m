% the previous reshape function do illunimation adjust when it is still
% 160x120. But that is not a good way. Because There is some region that
% has no information in it. They will mess things up. Now I will first
% reshape them to 128x128 then fill the no information region to the median
% value and find the background from real space local average. At last
% divide the image by this background. No Gassian window will be applied.
% a0 = reshape_128_128_112103(a,method)
% the method is 'bilinear' or'bicubic', the mothod of function imresize. 

function a0 = reshape_128_128_112103(a,method)

a = double(a);
asize = size(a);
% mean_a = mean(a(:))
a00 = sum(a,3)/asize(3);
a01 = a00 > 1 ; % This is the region where it has information.
% for i=1:asize(3),a(:,:,i) = a(:,:,i) + (1-a01)*median(a00(:)); end

% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
ay = sum(a01,2);
for i=1:33, ty(i) = sum(ay(i:i+127)); end 
y1 = find(max(ty)==ty); 
y0 = floor(median(y1)); % May get more than one maxima,choose the one in the middle

a02 = ones(128,128).*median(a00(:));
a02(:,5:124) = a00(y0:y0+127,1:120);
%mean(a02(:))
bg16 = blkproc(a02,[16,16],'mean(x(:))');
bg128 = imresize(bg16,[128,128],'bilinear'); %imagesc(bg128),colorbar, min(bg128(:))
%mean(bg128(:))
if min(bg128(:))==0, bg128 = bg128 + 0.01*max(bg128(:));  end
%Initialize a_out
a0 = zeros(128,128,asize(3)); 
a0(:,5:124,1:asize(3))=a(y0:y0+127,1:120,:);
for i=2:4
    a0(1:128,i,:) = a0(1:128,i,:) + 0.5^(5-i)*( a0(1:128,5,:) - a0(1:128,1,:) ) ;  
    a0(1:128,129-i,:) = a0(1:128,129-i,:) + 0.5^(5-i)*( a0(1:128,124,:) - a0(1:128,128,:) ) ; 
end
for i=1:asize(3),
    a0(:,:,i)=a0(:,:,i)./bg128;
end

