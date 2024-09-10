% p = find_k_640_mov(fname,N); Find the k's of all the images in the mov. The movie is made of 640x480 images. 


function p = find_k_640_mov(fname,N);
[b0,y0]=background_640_mov(fname,64,64,'bilinear');
fid=fopen(fname,'r');
for i=1:N,
    i = i,%clock
    a0= fread(fid,[640,480],'uchar');
    a = reshape_640_img(a0,b0,y0);
    a = a - mean(a(:)) ;
    a_fft = fftshift(abs(fft2(a)));
    a_fft_rt = xy2rt(a_fft,257,257,1:60,pi/360:pi/180:2*pi ) ;
    a_1d = sum(a_fft_rt).*(1:60);
    a_1d(1:5) = 0;
    p(i) = peak1d(a_1d(1:40));
    % if i==55, figure(1), subplot(2,2,1),imagesc(a), subplot(2,2,2), imagesc(a_fft), subplot(2,2,3), imagesc(a_fft_rt), subplot(2,2,4),plot(a_1d), pause, end
end

