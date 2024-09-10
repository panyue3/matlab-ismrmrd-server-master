% KLT Interpolation
% a_out = KLT_Interp(a_0, x0, x1)
% a_0:  original data taken at x0
% x0:   temporal or spatial sampling point
% x1:   new sampling point

% load C:\MATLAB7\work\Work_Space_Dual_CPU\2007\2007_09_05_MW\raw_data_32
% x0 = 3:4:128;
% x1 = 1:128;
% a_0 = a_32(:,:,x0);

function a_out = KLT_Interp(a_0, x0, x1)
s = size(a_0);
switch length(s)
    case 2
        a_1 = a_0; clear a_0
        s0 = 0;
    case 3
        a_1 = reshape(a_0, s(1)*s(2), s(3)); clear a_0
        s0 = 1;
    otherwise
        'Error, a_0 must be 2-D or 3-D !'
        return
end
s1 = size(a_1);        
C = a_1'*a_1/s1(1);
[V, D] = eig((C+C')/2);
a_I = a_1*V; % Eigenimages
V0 = interp1(x0, V, x1, 'spline');
a_1 = a_I*V0';

if s0==1
    a_out = reshape(a_1, s(1), s(2), length(x1));
else
    a_out = a_1;
end

%for i=x1, imagesc([a_32(:,:,i), a_out(:,:,i)]), axis image, title(num2str(i)); pause(0.1), end








