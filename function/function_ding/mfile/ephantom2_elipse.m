function data = ephantom2_elipse(kx,ky,par,dpar,factor)
%
% generates a 2D k-space elipse (called by ephantom2)
%
% Usage: data = ephantom2_elipse(kx,ky,par,dpar,factor);
%
% It does not check parameters! You shoud do that in ephantom2
%
% kx,ky: kspace position of samples
% par: [center_x center_y semiaisx_x semiaxis_yy]
% dpar: [dcenter_x dcenter_y dsemiaisx_x dsemiaxis_yy]
% factor: portion of dpar to add to par
%
% Pablo Irarrazaval
% 25-11-03 Creation
% 27-11-03 Add dpar and factor

ipar = par+factor*dpar;
arg = sqrt(ipar(3)^2*kx.^2 + ipar(4)^2*ky.^2);
[x y] = find(abs(arg)<1e-6); arg(x,y) = 1e-6; % avoid zeros

data = prod(size(kx))*ipar(3)*ipar(4)*...
       0.5*besselj(1,pi*arg)./arg;
data = exp(-i*2*pi*(ipar(1)*kx+ipar(2)*ky)).*data;
