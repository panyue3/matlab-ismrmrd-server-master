% This is my KL transform function, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep [a_r,V,D] = KLT_lp_Filter(a,c1), a is
% a 3-D array, the third dimension is the frame number, c1 is the # of
% eigenimage number range the user want to cut.
% This version has the FAST algorithm: Don't calculate the Eigen Images. 

function [a_r,V_0,D] = KLT_lp_Filter(a,c1);
%c0 = clock
%a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    if c1 <1 | c1 >N 
        '1 < c1 <  # of images'
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
        [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
        
        % The advantage of this method is: it does not calculate the
        % eigenimage, but use V_in =\tilda{V}*V'.
        % V_in is the inverse matrix of V (orthogonal matrix)
        V_t = V';
        V_0 = V;
        % determine which one have to let
        c_1 = round(c1);
        %V(:,1:end-c_2+1) = 0; % remember: this is in descending order! 
        V(:,c_1-1:end) = 0;
        %        V_in = single(V*V');
        %        V_in = (V*V'); % Think this is wrong. It should be V_in = (V*V_t);
        %        2007-05-31
        V_in = (V*V_t);
        %figure(1), imagesc(D), axis image, figure(2),imagesc(V), axis image, pause
        % a_r is the reconstruction of original a matrix
        %        a_r = single(zeros(size(a)));
        %temp = b*V_in'; clear b,
        %a_r = (reshape(b*V_in' + b_mean, [s(1),s(2),s(3)] ) ) ;, clear b
        a_r = (reshape(b*V_in' , [s(1),s(2),s(3)] ) ) ; clear b % Get rid of the mean
    end
    %    clock - c0
end

