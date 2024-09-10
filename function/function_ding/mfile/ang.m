%
% find the angle of (x,y), the value range of angle is from [-pi,pi]
%

function a = ang(x,y)

a = atan(y/x);
if x<0&y>=0
    a = a + pi;
elseif x<0&y<=0
    a = a - pi;
end
