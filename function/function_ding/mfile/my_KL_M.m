% This is a modified KL transform filter. In this filter all the mean value
% of the images are set to the same, then filter them. At last, times the
% original mean value to make the mean different again.

% Non-finished work !!!!!!

function a_r = my_KL_M(a,r);

a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    if r>1|r<=0
        'The ratio must belong to (0 1]'
    else
        %clock,
        b = single(zeros(N,s(1)*s(2)));
        a_mean = mean(a(:)); % Mean for all the data
        for i=1:N
            temp = (a(:,:,i));
            b(i, :) = temp(:) ; % This is the covariance matrix
        end
        A = b*b'; clear b;
        %clock,
        [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
        V = single(V);
        D = single(D);
        %clock,
        % Try to reconstruct the eigen images I. The first one (No.20) should be the mean
        I = single(zeros(size(a)));
        for i=1:N
            temp = single(zeros(s(1),s(2)));
            for j=1:N
                temp = temp + V(j,i)*a(:,:,j);
            end
            I(:,:,i) = temp;
        end
        %clock,
        % V_in is the inverse matrix of V (orthogonal matrix)
        V_in = single(V');

        % a_r is the reconstruction of original a matrix
        a_r = single(zeros(size(a)));
        for i=1:N
            temp = single(zeros(s(1),s(2)));
            for j=N-round(N*r)+1:N
                 temp = temp + V_in(j,i)*I(:,:,j);
            end
            % This is to fix the negative pixel value problem.
            a_r(:,:,i) = temp.*(temp>0);
        end
        
    end
    
end











