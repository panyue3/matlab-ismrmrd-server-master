% Today is 10_06_2004, I need to process some data file which has 100
% 640x480 images. I need a script to reshape it to 512x512.

function a0 = reshape_640_img(a,b0,y0)

a = double(a);
asize = size(a);
if asize(1)==480, a = a' ; end 
% Get rid of the zeros in the background
b0 = b0-min(b0(:)) + 0.001*max(b0(:));
% Get the scaled image
%a = a./b;

%a0 = ones(512,512)*median(a(:)); 
a0 = zeros(512,512);
a0(:,17:496)=a(y0:y0+511,1:480); %imagesc(a0), figure(2), imagesc(b0), pause
a0 = a0./b0; %imagesc(a0), pause,
a0(:,1:16) = mean(a0(:));  a0(:,497:512) = mean(a0(:)); 

% Smooth the boundary
for i=2:4
    a0(1:512,i) = a0(1:512,i) + 0.5^(5-i)*( a0(1:512,5) - a0(1:512,1) ) ;  
    a0(1:512,513-i) = a0(1:512,513-i) + 0.5^(5-i)*( a0(1:512,508) - a0(1:512,512) ) ; 
end


