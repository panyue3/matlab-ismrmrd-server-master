% This is my KL transform filter, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep [a_r,V,D] = my_KL_reshape(a,r), a is
% a 3-D array, the third dimension is the frame number, r is a number
% smaller than 1.0, that is the ratio of the eign images you want to keep.
% This version has the FAST algorithm: Don't calculate the Eigen Images. 

function [a_r,V_0,D] = my_KL_reshape(a,r);
%c0 = clock
%a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    if r>1|r<=0
        'The ratio must belong to (0 1]'
    else
        %        clock-c0,
        %b = zeros(s(1)*s(2),s(3),'single');
        b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
        t_mean = mean(b,1);
        b_mean = ones(s(1)*s(2),1)*t_mean;
        b = b - b_mean; %clear b_mean
        b_std = std(b,0,1);
        A = (b'*b)/(s(1)*s(2)); % clear b; % Imagesc(A), pause,
        %        clock-c0,
        [V,D] = (eig((A+A')/2)); % This is to diagonalize the covariance matrix
        
        % The advantage of this method is: it does not calculate the
        % eigenimage, but use V_in =\tilda{V}*V'.
        % V_in is the inverse matrix of V (orthogonal matrix)
        V_t = V';
        V_0 = V;
        V(:,1:round(N*(1-r))) = 0;N*(1-r);
        %        V_in = single(V*V');
        %        V_in = (V*V'); % Think this is wrong. It should be V_in = (V*V_t);
        %        2007-05-31
        V_in = (V*V_t);
        %figure(1), imagesc(D), axis image, figure(2),imagesc(V), axis image, pause
        % a_r is the reconstruction of original a matrix
        %        a_r = single(zeros(size(a)));
        %temp = b*V_in'; clear b,
        a_r = (reshape(b*V_in' + b_mean, [s(1),s(2),s(3)] ) ) ;, clear b
        %a_r = (reshape(b*V_in' , [s(1),s(2),s(3)] ) ) ; clear b % Get rid of the mean
    end
    %    clock - c0
end

