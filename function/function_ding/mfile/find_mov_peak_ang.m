% find the same peak position on different images, 
% then get the angular velocity 
% function [peak_pos,ang_vel] = find_mov_peak_ang(fname,k0)

function [peak_pos,ang_vel,p2,p3,p2_1,p2_2] = find_mov_peak_ang(fname,k0)

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
    i = i+1,
    a0 = zeros(128,128);     a0(:,5:124)=a00(y0:y0+127,1:120);
    for j=2:4
    a0(1:128,j) = a0(1:128,j) + 0.5^(5-j)*( a0(1:128,5) - a0(1:128,1) ) ;  
    a0(1:128,129-j) = a0(1:128,129-j) + 0.5^(5-j)*( a0(1:128,124) - a0(1:128,128) ) ; 
    end
    a1 = a0(:,:)./bg128;
    %median_a1 = median(a1),
    clear a0,       
% a = readin_160_120_file(fname);
%a1 = reshape_128_128_112103(a,'bilinear');
%a_size = size(a1),
%for i=1:a_size(3)
    afft(1:128,1:128) = abs(fftshift(fft2(a1(:,:)))) ;    
    a = xy2rt(afft(:,:),65,65,1:50,0:pi/180:2*pi-0.001) ; 
    e1(1:360) = sum(a(:,k0-2:k0+2),2);          % plot(e1)%e1 = e1 - mean(e1(:)) ; plot(e1)
    e2(1:360) = sum(a(:,round(1.732*k0)-2:round(1.732*k0)+2),2);
    if i==1,
        p(i) = peak1d(e1(:));
        p0(i) = mod(p(i),60);
        % Find the initial peak position
        p(i) = 104 + round(p0(i)) + peak1d(e1(120+round(p0(i))-15:120+round(p0(i))+15));
        p2(i) = floor(p(i))-66 + peak1d(e1( (floor(p(i))-65) : (floor(p(i))-55) ));
        p3(i) = floor(p(i))+54 + peak1d(e1( (floor(p(i))+55) : (floor(p(i))+65) ));
        % The following is th first harmonics, find the angle of them.
        p2_1(i) = floor(p(i))-36 + peak1d(e2( (floor(p(i))-35) : (floor(p(i))-25) )); 
        p2_2(i) = floor(p(i))+24 + peak1d(e2( (floor(p(i))+25) : (floor(p(i))+35) )); 
    else
        p0(i) = round(p(i-1)); 
        ang = mod(p0(i)-1,360) + 1;
        % solve the problem the the the angle may be smaller than 0 or
        % larger than 360. If the new peak is within +/- 30 degree of the
        % old peak, it will be found.
        theta = 20;
        peak_1 = circle_domain(theta,ang);% if i > 280 ,e1(peak_1), end
        p_temp = peak1d(e1(peak_1));
        p(i) = round(p(i-1))-theta-1 + p_temp;
        
        
        p02(i) = round(p2(i-1)); 
        ang = mod(p02(i)-1,360) + 1;
        theta = 20;
        peak_1 = circle_domain(theta,ang);
        p_temp = peak1d(e1(peak_1));
        p2(i) = round(p2(i-1))-theta-1 + p_temp;
        
        
        p03(i) = round(p3(i-1)); 
        ang = mod(p03(i)-1,360) + 1;
        theta = 20;
        peak_1 = circle_domain(theta,ang);
        p_temp = peak1d(e1(peak_1));
        p3(i) = round(p3(i-1))-theta-1 + p_temp;
        
        p02_1(i) = round(p2_1(i-1)); 
        ang = mod(p02_1(i)-1,360) + 1;
        theta = 20;
        peak_1 = circle_domain(theta,ang);
        p_temp = peak1d(e2(peak_1));
        p2_1(i) = round(p2_1(i-1))-theta-1 + p_temp;
        
        p02_2(i) = round(p2_2(i-1)); 
        ang = mod(p02_2(i)-1,360) + 1;
        theta = 20;
        peak_1 = circle_domain(theta,ang);
        p_temp = peak1d(e2(peak_1));
        p2_2(i) = round(p2_2(i-1))-theta-1 + p_temp;
            
    end
    afft=zeros(128,128); a = zeros(128,128);e1 = zeros(1,360); a1 = zeros(128,128);
    a00 =0 ; a00=fread(fid,[160,120],'uchar'); 
end

slope = polyfit(1:i,p,1);
peak_pos = p ;
ang_vel = slope;