function data = ephantom2_rectangle(kx,ky,par,dpar,factor)
%
% generates a 2D k-space rectangle (called by ephantom2)
%
% Usage: data = ephantom2_rectangle(kx,ky,par,dpar,factor);
%
% It does not check parameters! You shoud do that in ephantom2
%
% kx,ky: kspace position of samples
% par: [centerx centery sidex sidey]
% dpar: [dcenterx dcentery dsidex dsidey]
% factor: portion of dpar to add to par
%
% Pablo Irarrazaval
% 25-11-03
% 27-11-03 Add dpar and factor

ipar = par+factor*dpar;
data = prod(size(kx))*ipar(3)*ipar(4)*sinc(ipar(3)*kx).*sinc(ipar(4)*ky);
data = exp(-i*2*pi*(ipar(1)*kx+ipar(2)*ky)).*data;

% figure(1), imagesc([sinc(ipar(3)*kx), sinc(ipar(4)*ky), sinc(ipar(3)*kx).*sinc(ipar(4)*ky)])
% figure(2), imagesc([abs(data)])
% figure(3), imagesc(abs(ifftshift(ifft2(data))).^0.25)
% figure(4), plot(1:size(kx, 2), real(data(size(kx, 1)/2+1, :)), '--', 1:size(kx, 2), imag(data(size(kx, 1)/2+1, :)), '-')
% size(kx, 1)/2
% ipar = ipar

