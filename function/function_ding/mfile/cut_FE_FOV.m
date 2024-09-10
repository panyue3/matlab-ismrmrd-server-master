% This is to Cut the FOV of FE direction to 50% of the original
% a = cut_FE_FOV(a)
% a: is the k-space data, the first dimension is the FE direction

function a = cut_FE_FOV(a)

s = size(a);
s_out = s;
s_out(1) = s(1)/2;
a = reshape(a, [s(1), prod(s(2:end))]);

temp = fftshift(ifft(a, [], 1), 1);

a_ifft = temp( round(s(1)/4) + 1: round(s(1)/4) + s(1)/2, : );
a = fft(ifftshift(a_ifft, 1), [], 1);
a = reshape(a, s_out);

% switch length(s)
%     case 2
%         a_ifft = temp( round(s(1)/4) + 1: round(s(1)/4) + s(1)/2, : );
%     case 3
%         a_ifft = temp( round(s(1)/4) + 1: round(s(1)/4) + s(1)/2, :, : );%'3'
%     case 4
%         a_ifft = temp( round(s(1)/4) + 1: round(s(1)/4) + s(1)/2, :, :, : );
%     case 5
%         a_ifft = temp( round(s(1)/4) + 1: round(s(1)/4) + s(1)/2, :, :, :, : );
%     otherwise
%         'Error! The size of the input is not right'
%         return
% end
% size(a_ifft);
% a = fft(ifftshift(a_ifft, 1), [], 1);





