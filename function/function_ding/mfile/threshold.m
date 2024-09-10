% Apply the shrinkage method to a data matrix
% [b, r] = threshold(a, c)
% a: input real/complex data matrix
% c: threshold amount, (noise std)
% b: data matrix after thresholding
% r: ratio of retained pixels 0<=r<=1

function [b, r] = threshold(a, c)
b = a;
r = 1;
c = 1.0*c;
if c < 0
    'Error! parameter c can not < 0'
    return
elseif isreal(a)
    % Only real part
    temp = a.^2 -c^2;         % subtraction 
    mask = temp > 0;            % find of all positive values
    temp = sqrt(a.*mask);    % take only positive values
    b = sign(a).*temp;
    r = sum(mask(:))/prod(size(mask));
else
%     a_1 = real(a);
%     a_2 = imag(a);
%     % Real part
%     temp = a_1.^2 -c^2;         % subtraction shrinkage
%     mask = temp > 0;            % position of all positive values
%     temp = sqrt(temp.*mask);    % take only positive values
%     b_1 = sign(a_1).*temp;
%     r(1) = sum(mask(:))/prod(size(mask));
%     % Imag part
%     temp = a_2.^2 -c^2;         % subtraction shrinkage
%     mask = temp > 0;            % position of all positive values
%     temp = sqrt(temp.*mask);    % take only positive values
%     b_2 = sign(a_2).*temp;
%     r(2) = sum(mask(:))/prod(size(mask));
%     % Return
%     b = complex(b_1, b_2); % Combine real and imag
    
    theta = angle(a);
    temp = abs(a).^2 - 2*c^2;
    mask = temp > 0;            % position of all positive values
    temp = sqrt(temp.*mask);    % take only positive values
    b = temp.*exp(sqrt(-1)*theta);
    r = sum(mask(:))/prod(size(mask));
end
return




