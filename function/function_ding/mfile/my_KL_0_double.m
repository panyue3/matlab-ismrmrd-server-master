% This is my KL transform function, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep [a_r, V, D] = my_KL_0(a,r), a is
% a 3-D array, the third dimension is the frame number, r is a number
% smaller than 1.0, that is the ratio of the eign images you want to keep.

% This version get rid of the mean of each images and add them back after
% the filtering

function [a_r, V, D] = my_KL_0_double(a,r);

s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    if r>1|r<=0
        'The ratio must belong to (0 1]'
    else
        %clock,
        %b = single(zeros(N,s(1)*s(2)));
        b = (zeros(N,s(1)*s(2)));
        for i=1:N
            temp = (a(:,:,i));
            mean_a(i) = mean(temp(:)); % Find the mean of each image
            temp = temp - mean_a(i); % Get rid of the mean of each image.
            b(i, :) = temp(:) ; % This is the covariance matrix
            b_std(i) = std(temp(:)); % Standard deviation of each image
        end
        A = b*b'./(b_std'*b_std); clear b; % Imagesc(A), pause,
        %clock,
        [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
%         V = single(V);
%         D = single(D);
        %clock,
        % Try to reconstruct the eigen images. The first one (No.20) should be the mean
        %I = single(zeros(size(a)));
        I = (zeros(size(a)));
        for i=1:N
            %temp = single(zeros(s(1),s(2)));
            temp = (zeros(s(1),s(2)));
            for j=1:N
                temp = temp + V(j,i)*(a(:,:,j)-mean_a(j))/b_std(j);
                % Substract the mean, scale each image by the std, 
            end
            I(:,:,i) = temp;
        end
        %clock,
        % V_in is the inverse matrix of V (orthogonal matrix)
        %V_in = single(V');
        V_in = (V');

        % a_r is the reconstruction of original a matrix
        %a_r = single(zeros(size(a)));
        a_r = (zeros(size(a)));
        for i=1:N
            %temp = single(zeros(s(1),s(2)));
            temp = (zeros(s(1),s(2)));
            for j=N-round(N*r)+1:N
                 temp = temp + V_in(j,i)*I(:,:,j);
            end
            temp = temp * b_std(i) + mean_a(i); % Scale it back and add the mean
            a_r(:,:,i) =  temp.*(temp>0);
        end
        
    end
    
end











