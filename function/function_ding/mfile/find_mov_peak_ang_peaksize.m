% find the same peak position on different images, 
% then get the angular velocity 
% Then get the uncertainty of the peak(std value)
% function [peak_pos,ang_vel] = find_mov_peak_ang_peaksize(fname,k0)

function [peak_pos,ang_vel,p_r_pos,delta_p_r_pos, delta_p_theta] = find_mov_peak_ang_peaksize(fname,k0)

k0 = k0*4; % image will be tile 4 times larger
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

fid = fopen(fname,'r');  a00=0; i=0, a00=fread(fid,[160,120],'uchar');      
while prod(size(a00))==19200,  % Read in one image file a time, save memory
    i = i+1,
    a0 = zeros(128,128);        a0(:,5:124)=a00(y0:y0+127,1:120);
    % The next for looop is to smooth the boundary
    for j=2:4
    a0(1:128,j) = a0(1:128,j) + 0.5^(5-j)*( a0(1:128,5) - a0(1:128,1) ) ;  
    a0(1:128,129-j) = a0(1:128,129-j) + 0.5^(5-j)*( a0(1:128,124) - a0(1:128,128) ) ; 
    end
    a1_0 = a0(:,:)./bg128;      a1 = zeros(512,512); 
    % Imbed the image into 512x512 domain
    a1(193:320,193:320) = a1_0; clear a0, clear a1_0;
    % Now process data in Fourier Space
    afft(1:512,1:512) = abs(fftshift(fft2(a1(:,:)))) ;    
    a = xy2rt(afft(:,:),257,257,1:200,0:pi/180:2*pi-0.001) ;   
    e1(1:360) = sum(a(:,k0-6:k0+10),2);          
    if i==1,
        p(i) = peak1d(e1(:));
        p0(i) = mod(p(i),60);
        p(i) = 104 + round(p0(i)) + peak1d(e1(120+round(p0(i))-15:120+round(p0(i))+15));
    else
        p0(i) = round(p(i-1)); 
        ang = mod(p0(i)-1,360) + 1;
        % solve the problem the the the angle may be smaller than 0 or
        % larger than 360. If the new peak is within +/- 30 degree of the
        % old peak, it will be found.
        theta = 20;
        if ang < theta+1;       peak_1 = [mod(ang-theta-1,360)+1:360 1:ang + theta]; 
        elseif ang > 360-theta, peak_1 = [ang-theta-1:360 1:mod(ang+theta,360)];
        else                    peak_1 = [ang-theta:ang+theta];
        end
    
        p_temp = peak1d(e1(peak_1));
        p(i) = round(p(i-1))-theta-1 + p_temp;
    end
    pr = sum(a(:,k0-10:k0+10),1);                           [pr_pos(i),pr_width(i)]= peak_1d_width(pr);
    p_theta = mod(p(i), 60 ) + 60;       
    ptheta = sum(a(floor(p_theta-10:p_theta+10),k0-10:k0+10),2) ;  [p_theta_pos(i),p_theta_width(i)]= peak_1d_width(ptheta);
    p_theta_width(i) = p_theta_width(i)*(pi/180) * ((k0-9+ pr_pos(i))*0.25 );
    afft=zeros(512,512); a = zeros(512,512);e1 = zeros(1,360); 
    a00 =0 ; a00=fread(fid,[160,120],'uchar'); 
    pause(0.01)
end
fclose(fid)
slope = polyfit(1:i,p,1);
peak_pos = p ;
ang_vel = slope;
p_r_pos = mean((k0-9+pr_pos(:))*0.25);     delta_p_r_pos = mean(pr_width(:)*0.25);
delta_p_theta = mean(p_theta_width(:));