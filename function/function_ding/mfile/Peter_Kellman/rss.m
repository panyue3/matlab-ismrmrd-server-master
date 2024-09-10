function mag = rss(f,dim);
% function  mag = rss(f,dim);
%
% computes the root-sum-of-squares magnitude
% e.g., if   f(row,col,coil) is a multi-coil complex image
%       then mag=rss(f,3)
%               =sqrt( sum ( abs(f(row,col,coil))  ))
%        where sum is over coil (dimension 3)

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************

if nargin==1
    dim=ndims(f);
else
    if isempty(dim); dim=ndims(f); end
end

mag=sqrt(sum(real(f).^2 + imag(f).^2,dim));

return