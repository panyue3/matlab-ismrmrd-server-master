% function Cutoff  = FWHM_Cutoff(a), Cutoff = # of eigenimages should be kept
% Find the cutoff determined by FWHM > 2.0 of the autocorrelation function of image series a.
% First find the eigenimages of a, 
% Then find the FWHM of each eigenimage
% At last, calculate the cutoff  

function Cutoff = FWHM_Cutoff(a)

Cutoff = 0;
if ndims(a) ~= 3 % E is not a vector
    'Error! Input is not a 3-D matrix !',
    Cutoff = 0; 
    return 
end
s = size(a);
a = double(a);
x_c = round((s(2)+1)/2); % Center point
y_c = round((s(1)+1)/2); % Center point
[a_I, V, D] = KL_Eigenimage(a);
for i=1:s(3)
    t = a_I(:,:,i);
    a_t = my_corr2(t,t);
    %if ( a_t(y_c+1,x_c) + a_t(y_c-1,x_c) + a_t(y_c,x_c+1) + a_t(y_c,x_c-1) ) > 2 % FWHM > 2
    if ( a_t(y_c+1,x_c)>0.5 & a_t(y_c-1,x_c)>0.5 & a_t(y_c,x_c+1)>0.5 & a_t(y_c,x_c-1)>0.5 ) % FWHM > 2
        Cutoff = s(3) - i;
        break
    end
end

s = size(a);
a_m = max(a(:));

% x_d = round(x_c/2); % x-coordinate width
% y_d = round(y_c/2); % y-coordinate width
% [x_0,y_0] = meshgrid(x_c-x_d:x_c+x_d, y_c-y_d:y_c+y_d);
% [x_I,y_I] = meshgrid(x_c-x_d:0.5:x_c+x_d, y_c-y_d:0.5:y_c+y_d);
% 
% a_0 = interp2( x_0,y_0, a(y_c-y_d:y_c+y_d, x_c-x_d:x_c+x_d),x_I,y_I,  'spline');
% s0 = size(a_0);
% % figure(1), imagesc(a), figure(2),imagesc(a_0),figure(3)
% [x,y] = contour(1:s0(2),1:s0(1),a_0,[a_m/2 a_m/2]);%, axis image, pause
% close all,
% x_c = round((s0(2)+1)/2); % Center point
% y_c = round((s0(1)+1)/2); % Center point
% 
% r = 2*sqrt(polyarea(x(1,2:end),x(2,2:end))/pi) / 2;% FW -> 2*; interp2 by 2 -> /2.
% 
% r_max = 2*max(sqrt( ( x(1,2:end) - x_c ).^2 + ( x(2,2:end) - y_c ).^2 )) / 2;

%sqrt( ( x(1,2:end) - x_c ).^2 + ( x(2,2:end) - y_c ).^2 )
%x_c,y_c
