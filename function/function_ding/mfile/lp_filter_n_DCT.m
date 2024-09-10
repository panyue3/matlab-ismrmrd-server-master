% lp_filter_n: Low pass filter 3-D array using flat filter plus a Gaussian smooth edge.
% a = lp_filter_3(b,r), 0<r,sigma<1, r is the cutoff frequency scaled
% by the max frequency, sigma is the half-height width of Gaussian edge
% b: input data
% r: frequency cutoff
% sigma: Gaussian Roundoff
% It only works along the third dimension!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


function [a]=lp_filter_n_DCT(b,r)
%clock
s = size(b);
%b = double(b);
s2 = s(3); 
lox = (r*s2);
b = single(b);
%a=fftshift(fft(b-mb,[],3),3);
b_reshape = ( reshape( b, s(1)*s(2), s(3)) )'; clear b
cut_off = zeros(size(b_reshape)); % Initiate cut_off 
cut_off(1:lox,:) = 1; % Set the cutoff matrix
b_dct = dct(b_reshape).*cut_off; clear b_reshape
a = reshape(idct(b_dct)', s(1), s(2), s(3) ) ;


% a=fftshift(fft(b,[],3),3);
% z = zeros(s(3),1);
% 
% x =-s(3)/2:s(3)/2-1;
% 
% %clock
% 
% %c = reshape(a,[s(1)*s(2),s(3)]); % reshape to 2-D array
% %z = (abs(x)<=lox) +(abs(x) > lox).*exp(-(( abs(x)- lox).^2/sig)) ; % size(c),size(z), plot(z,'*-'), pause
% %z = (abs(x)<=lox) ; % size(c),size(z), plot(z,'*-'), pause
% %z0 = ones(s(1)*s(2),1)*z; 
% %c = c.*z0;
% %a = reshape(reshape(a,[s(1)*s(2),s(3)]).*( ones(s(1)*s(2),1)*(abs(x)<=lox) ) ,[s(1),s(2),s(3)]);
% L = find((1 - (abs(x)<=lox)) == 1) ; % plot(L), pause,
% a(:,:,L) = 0 ;
% 
% %clock
% % make the size of a and z the same size
% % if prod(double(size(a)==size(z))),
% %     a = a.*z;
% % else
% %     a = a.*z';
% % end
% %a=real(ifft(ifftshift(a, 3),[],3))+mb;
% a = real(ifft(ifftshift(a, 3),[],3));
%clock





