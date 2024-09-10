% find the same peak position on different images, 
% then get the angular velocity 
% function [peak_pos,ang_vel] = find_mov_peak_ang(fname,k0)

function [peak_pos,ang_vel] = find_mov_peak_ang_one(fname,k0)

a=zeros(160,120);
fid = fopen(fname,'r'); for i=1:40, a=a+fread(fid,[160,120],'uchar');end, fclose(fid)
a =a./40 ;
a01 = a > 1 ; % This is the region where it has information.
% for i=1:asize(3),a(:,:,i) = a(:,:,i) + (1-a01)*median(a00(:)); end

% This is a adaptive way to find the boundary of size 128
% y0 is the starting point
ay = sum(a01,2);
for i=1:33, ty(i) = sum(ay(i:i+127)); end 
y0 = floor(median(find(max(ty)==ty))); % May get more than one maxima,choose the one in the middle

a02 = ones(128,128).*median(a(:));
a02(:,5:124) = a(y0:y0+127,1:120);
bg16 = blkproc(a02,[16,16],'mean(x(:))');
bg128 = imresize(bg16,[128,128],'bilinear'); %imagesc(bg128),colorbar, min(bg128(:))
if min(bg128(:))==0, bg128 = bg128 + 0.01*max(bg128(:));  end
clear bg16, clear a02, clear ay, clear a01, clear a0,clear a;

fid = fopen(fname,'r');  a00=0; i=0, a00=fread(fid,[160,120],'uchar');      
while prod(size(a00))==19200,  
    if i>1000, p(1000)=20;
    a0 = zeros(128,128); a0(1:128,5:124)=a00(y0:y0+127,1:120);
    for j=2:4
    a0(1:128,j) = a0(1:128,j) + 0.5^(5-j)*( a0(1:128,5) - a0(1:128,1) ) ;  
    a0(1:128,129-j) = a0(1:128,129-j) + 0.5^(5-j)*( a0(1:128,124) - a0(1:128,128) ) ; 
    end
    a0 = a0(:,:)./bg128; 
    median_a0 = median(a0),
    clear a0,       
% a = readin_160_120_file(fname);
%a1 = reshape_128_128_112103(a,'bilinear');
%a_size = size(a1),
%for i=1:a_size(3)
    afft(1:128,1:128) = abs(fftshift(fft2(a0(:,:)))) ; a0=0;   median_afft = median(afft(:))
    a0 = xy2rt(afft(:,:),65,65,1:50,0:pi/180:2*pi-0.001) ; median_a = median(a0(:)),
    e1(1:360) = sum(a0(:,k0-2:k0+2),2);          % plot(e1)%e1 = e1 - mean(e1(:)) ; plot(e1)
    if i==1,
        p(i) = peak1d(e1(:));
        p0(i) = mod(p(i),60);
        p(i) = 104 + round(p0(i)) + peak1d(e1(120+round(p0(i))-15:120+round(p0(i))+15));
    else
        p0(i) = round(p(i-1)); 
        ang = mod(p0(i)-1,360) + 1,
        % solve the problem the the the angle may be smaller than 0 or
        % larger than 360. If the new peak is within +/- 30 degree of the
        % old peak, it will be found.
        theta = 20;
        if ang < theta+1,       peak_1 = [mod(ang-theta-1,360)+1:360 1:ang + theta]; 
        elseif ang > 360-theta, peak_1 = [ang-theta-1:360 1:mod(ang+theta,360)];
        else                    peak_1 = [ang-theta:ang+theta];
        end
        % e1(peak_1),
        p_temp = peak1d(e1(peak_1));
        p(i) = round(p(i-1))-theta-1 + p_temp;% peak1d(e1(round(p(i-1))-15:round(p(i-1))+15,i));
    end
    end%i,  p(i),   plot(e1(:,i)),  pause
    afft=zeros(128,128); a = zeros(128,128);e1 = zeros(1,360); a0=0;
    a00 =0 ; a00=fread(fid,[160,120],'uchar'); 
end

slope = polyfit(1:i,p,1);
peak_pos = p ;
ang_vel = slope;