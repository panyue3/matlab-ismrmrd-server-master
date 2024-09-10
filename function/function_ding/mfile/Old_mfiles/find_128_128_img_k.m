% Find the primary k of a image, this image is a 2-D matrix, the size is
% 128*128. The illumination is uniform, a band pass filter and a Gaussian 
% window has applied on it. For example, the output of reshape_128_128_093003.
% k = find_128_128_img_k(a)

function k = find_128_128_img_k(a)
size_a = size(a) 
if size(size_a)~=2,
    'The input is not a 2-D matrix'
    k = -1;
    return
end

if size_a(1)~=size_a(2),
    'The two dimension is not the same size'
    k = -2;
    return
end

a = hpfilter(a,0.0618);
c = abs(fftshift(fft2(a)));
%x0 = round(size_a(1)/2+0.25);
d = xy2rt(c,65,65,1:60,0:0.1:2*pi);                 %figure(1),imagesc(d)
e = sum(d,1).*(1:60);                               %figure(2),plot(e)
k = peak1d(e);
