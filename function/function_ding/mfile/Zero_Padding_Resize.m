% This function resize the image using k-space zero padding method to avoid
% any extra artifact caused by interpolation.
% function b = Zero_Padding_Resize(a,x,y)
% a: 2-D image or 3-D image series.
% x: size of frequence encoding direction
% y: size of phase encoding direction

function b = Zero_Padding_Resize(a, x, y)

b = 0;
s = size(a);
sx_0 = round((s(1)+1)/2); % Find the center point in k-space
sy_0 = round((s(2)+1)/2);

x_0 = round((x + 1)/2); % Find the center point
y_0 = round((y + 1)/2);

t_x = x_0 - sx_0 ;
t_y = y_0 - sy_0 ;

if length(s) == 1, 'Error! Input Must Be a 2-D or 3-D Matrix!' , return, end
if length(s) > 3, 'Error! Input Must Be a 2-D or 3-D Matrix!' , return, end
if (t_x < 0) | (t_y < 0),  'Error! Output Image Size Cannot Smaller Than Input Image Size' , return, end

% Tukey Window
TW_x = tukeywin(s(1),20/s(1)); TW_y = tukeywin(s(2)+2, 20/(2+s(2)) )'; % Window width ~= 4 
TW = TW_x*TW_y(1, 2:end-1);  % figure(1), imagesc(TW), axis image,
%TW = ones(s(1), 1)*TW_y(1, 2:end-1);  figure(1), imagesc(TW), axis image, TW_y(1, 2:end-1)

if length(s) == 2,
    a_fft = fftshift(fft2(a)).*TW;
    b_fft = zeros(x,y);
    b_fft( 1+t_x:s(1)+t_x, 1+t_y:s(2)+t_y ) = a_fft *(x*y)/(s(1)*s(2)) ; %imagesc(abs(b_fft))
    b = ifft2(ifftshift(b_fft));% imagesc(abs(b)), pause,
elseif  length(s) == 3,
    b = zeros(x, y, s(3));
    for i=1:s(3),
        a_fft = fftshift(fft2(a(:,:,i))).*TW;  % figure(2), imagesc(log(abs( fftshift(fft2(a(:,:,i))) )+0.001)), axis image, %pause, % size(a_fft);
        b_fft = zeros(x,y); % size(1+t_x:s(1)+t_x), size(1+t_y:s(2)+t_y);
        %b_fft( 1+t_x:s(1)+t_x, 1+t_y:s(2)+t_y ) = a_fft *(x*y)/(s(1)*s(2)) ; %imagesc(abs(b_fft))
        b_fft( (1+t_x):(s(1)+t_x), (1+t_y):(s(2)+t_y) ) = a_fft *(x*y)/(s(1)*s(2));  % figure(3), imagesc(log(abs(b_fft)+0.01)), axis image, % pause
        b(:,:,i) = ifft2(ifftshift(b_fft)); % figure(4), imagesc(log(abs(b(:,:,i))+0.01)), axis image, pause
    end
else
    return
end






