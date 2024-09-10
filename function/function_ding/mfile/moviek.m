% function [k,spec,ft] = moviek(filein)
% k is the total k, sepc is the 1-D sepctrum
% ft is the 2-D fft

%function [k,spec,ft] = moviek(filein)
function k = moviek(filein)

i=1; N=128;n=0;factor=4;
fid=fopen(filein,'r');
a=fread(fid,[640,480],'uchar');
% figure(3);imagesc(a);

w = hanning(256); v = hanning(256);
win = w*v';

% circle mask
%   [x0,y0] = meshgrid(1:480,1:640);size(x0)
%   mask = (sqrt((x0-235).^2+(y0-305).^2)< 222);
% Apply mask
%   a0 = a.*mask+mean(a(:))*(1-mask);
%  figure(4); imagesc(a0);
%% Find the envelope
%   b=lpfilter(a0,0.05,.06);

while prod(size(a))==640*480,

  
%    if i>240&i<270    
%       n=n+1,
       a = a(192:447,112:367);
       b=lpfilter(a,0.05,.06);
       a = a./b;
%      a = a.*win; 
       a = a - mean(a(:));    
%      [spec(n,:),ft(n,:,:)]=spectrum(a);

%    a0 = a.*mask+mean(a(:))*(1-mask);

%    a0=a0./b; a=0;
%    a(1:512,1:480) = a0(51:562,1:480);
%    a(1:512,481:512) = 1;

      a = deci(a,factor); a = embed(a,factor);
%     imagesc(a);
      k(i) = roughk(a)/factor,
%   end
 a=fread(fid,[640,480],'uchar');
  i=i+1
end


