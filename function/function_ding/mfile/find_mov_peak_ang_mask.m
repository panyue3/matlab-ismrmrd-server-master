% find the same peak position on different images, each image divided into
% three ring. Find the FFT peak position of each ring.
% then get the angular velocity 
% function [peak_pos,ang_vel] = find_mov_peak_ang(fname,k0,m1,m2,m3)

function [peak_pos_1,peak_pos_2,peak_pos_3] = find_mov_peak_ang(fname,k0,m1,m2,m3)

% My idea is first find the peak position of the whole pattern, then divide
% the peak into 3 parts and then find the peak positions of eah of the
% parts.

[ b00,y00] =  background_mov(fname,12,12,'bicubic');
[yc,xc] = find_insert_rotation_center(fname);

fid = fopen(fname,'r');  a00=0; i=0, a00=fread(fid,[160,120],'uchar');      
while prod(size(a00))==19200,  
    i = i+1,
    a1 = reshape_128_img( a00,b00,y00 );
    
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
            
    end
    afft=zeros(128,128); a = zeros(128,128);e1 = zeros(1,360); a1 = zeros(128,128);
    a00 =0 ; a00=fread(fid,[160,120],'uchar'); 
end

slope = polyfit(1:i,p,1);
peak_pos = p ;
ang_vel = slope;