% [Img_out, Img_temp] = deapodization(Img_in, Ker_func, s_de)
% Img_in:   Input image,
% Ker_func: k-space deapodization kernel
% s_de:     size of deapodization image size, 1x2 array
% Img_temp: The intensity correction map

% 2017-07-27: added Img_temp in the output

function [Img_out, Img_temp] = deapodization(Img_in, Ker_func, s_de)

s_im = size(Img_in);
if length(s_im) == 2 % make sure it can handle 2D/3D data
    s_im(3) = 1;
end
Img_out = zeros(s_im);
s_kr = size(Ker_func);
if nargin == 2,
    s_de = s_im;
end
Img_temp = zeros( s_de(1), s_de(2) );

x_im_cen = floor((s_im(1)+1)/2); % Image x-center
y_im_cen = floor((s_im(2)+1)/2); % Image y-center
x_kr_cen = floor((s_kr(1)+1)/2); % Deapodization Kernel x-center
y_kr_cen = floor((s_kr(2)+1)/2); % Deapodization Kernel y-center
x_de_cen = floor(s_de(1)/2+1); % Image of deapodization x-center
y_de_cen = floor(s_de(2)/2+1); % Image of deapodization y-center


if mod(s_kr(1), 2) == 1 % odd number
    x_lim = x_de_cen + [-(s_kr(1)-1)/2:(s_kr(1)-1)/2];
else
    x_lim = x_de_cen + [-s_kr(1)/2:s_kr(1)/2-1];
end

if mod(s_kr(2), 2) == 1 % odd number
    y_lim = y_de_cen + [-(s_kr(2)-1)/2:(s_kr(2)-1)/2];
else
    y_lim = y_de_cen + [-s_kr(2)/2:s_kr(2)/2-1];
end

Img_temp(x_lim, y_lim) = Ker_func;
Img_temp = abs(fftshift(ifft2(ifftshift(Img_temp))));
Img_temp(Img_temp == 0) = 1;
Img_temp = Img_temp/max(Img_temp(:));

% Make deapodization image the same size as input image
if mod(s_im(1), 2) == 1 % odd number
    x_lim = x_de_cen + [-(s_im(1)-1)/2:(s_im(1)-1)/2];
else
    x_lim = x_de_cen + [-s_im(1)/2:s_im(1)/2-1];
end

if mod(s_im(2), 2) == 1 % odd number
    y_lim = y_de_cen + [-(s_im(2)-1)/2:(s_im(2)-1)/2];
else
    y_lim = y_de_cen + [-s_im(2)/2:s_im(2)/2-1];
end
Img_temp = Img_temp(x_lim, y_lim);


for i=1:s_im(3)
    Img_out(:,:,i) = Img_in(:,:,i)./Img_temp;
end
% figure(10), imagesc( Img_temp ), axis image, colorbar





