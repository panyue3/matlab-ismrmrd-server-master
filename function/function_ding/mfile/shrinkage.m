% Apply the shrinkage method to a data matrix
% [b, r] = shrinkage(a, c)
% a: input real/complex data matrix
% c: shrinkage amount, (noise std)
% b: data matrix after shrinkage
% r: ratio of retained pixels 0<=r<=1

function [b, r] = shrinkage(a, c)
b = a;
r = 1;
c = 1.0*c;
if c < 0
    'Error! parameter c can not < 0'
    return
elseif isreal(a) % Is matrix a real matrix? if Yes, then ...
    % Only real part
    temp = a.^2 -c^2;         % subtraction shrinkage
    mask = temp > 0;            % position of all positive values
    temp = sqrt(temp.*mask);    % take only positive values
    b = sign(a).*temp;          % sign(a) is the sign of each matrix element.
    r = sum(mask(:))/prod(size(mask));
else % Matrix a is complex matrix, 
    % The comment part is to shrink real and imag part independently
    % I do not thik it makes a big difference between the preserve phase angle approach 
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
    
    theta = angle(a); %Phase angle of complex number
    temp = abs(a).^2 - 2*c^2; % Shrink the amplitude
    mask = temp > 0;            % mask of all positive magnitude
    temp = sqrt(temp.*mask);    % keep only positive values
    b = temp.*exp(sqrt(-1)*theta); % preserve the phase, shrunk magnitude, original phase
    r = sum(mask(:))/prod(size(mask)); % find the ratio, prod(size(mask)) = # of elements of mask.
end
return




