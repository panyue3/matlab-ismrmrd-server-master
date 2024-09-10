

function spac_temp_a = spac_temp_fft(fname)

circle = 1;
a=zeros(160,120);
fid = fopen(fname,'r'); for i=1:40, a=a+fread(fid,[160,120],'uchar');end, fclose(fid)
a =a./40 ;
a01 = a > 1 ; % This is the region where it has information.
% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
ay = sum(a01,2);
for i=1:33, ty(i) = sum(ay(i:i+127)); end 
y0 = floor(median(find(max(ty)==ty))); % May get more than one maxima,choose the one in the middle

a02 = ones(128,128).*median(a(:));
a02(:,5:124) = a(y0:y0+127,1:120);
bg16 = blkproc(a02,[16,16],'mean(x(:))');
bg128 = imresize(bg16,[128,128],'bilinear'); 
if min(bg128(:))==0, bg128 = bg128 + 0.01*max(bg128(:));  end
clear bg16, clear a02, clear ay, clear a01, clear a0,clear a;

fid = fopen(fname,'r');  a00=fread(fid,[160,120],'uchar'); i = 0 ; a11=0;
while prod(size(a00))==19200,  % Read in one image file a time, save memory
    i = i+1,
    a0 = zeros(128,128);        a0(:,5:124)=a00(y0:y0+127,1:120);
    % The next for looop is to smooth the boundary
    for j=2:4
    a0(1:128,j) = a0(1:128,j) + 0.5^(5-j)*( a0(1:128,5) - a0(1:128,1) ) ;  
    a0(1:128,129-j) = a0(1:128,129-j) + 0.5^(5-j)*( a0(1:128,124) - a0(1:128,128) ) ; 
    end
    a1_0 = a0(:,:)./bg128; a11 = a11+a1_0;
    if circle == 1, 
        a1_0 = xy2rt(a1_0(:,:),60,74,1:60,0:pi/64:2*pi-0.001); 
        spac_temp(i,1:128) = sum(a1_0(1:128,49:51),2)';
    else    spac_temp(i,1:128) = a1_0(64,1:128);
    end
    a00=fread(fid,[160,120],'uchar');
    %plot(spac_temp(i,:)+i), hold on,
    
end
spac_temp = spac_temp -mean(spac_temp(:)); 
spac_temp_a = fftshift(fft2(spac_temp));
figure(1), imagesc(spac_temp)
%figure(4), imagesc(a11)
clear a*, clear b*,