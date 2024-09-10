% This is my KL transform function, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep a_r = my_KL_f(a,r), a is
% a 3-D array, the third dimension is the frame number, r is a number
% smaller than 1.0, that is the ratio of the eign images you want to keep.

% This version has the FAST algorithm: Don't calculate the Eigen Images. 
% Plus: try to get rid of the ringing effect by scale the eigenvector using
% the eigenvalues


function [a_r,V] = my_KL_NoRing(a,r);
c0 = clock
a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
    if r>1|r<=0
        'The ratio must belong to (0 1]'
    else
        %clock-c0,
        b = single(zeros(N,s(1)*s(2)));
        for i=1:N
            temp = (a(:,:,i));
            b(i, :) = temp(:) ; % This is the covariance matrix
        end
        A = b*b'; clear b;
        %clock-c0,
        [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
        V = single(V);
        D = single(D);
        %clock-c0,
        % The advantage of this method is: it does not calculate the
        % eigenimage, but use V_in =\tilda{V}*V'.
        % V_in is the inverse matrix of V (orthogonal matrix)
        V_t = V';
        c = round(N*(1-r)) ;        % Cut off criteria
        weight = (diag(ones(1,N))-diag([ones(1,c),zeros(1,N-c)]));
        weight = diag([ones(1,c),zeros(1,N-c)])*D/D(c,c) + weight;
        figure(1), for i=1:N, plot(i,log(D(i,i)+1),'markersize',10), hold on, end, hold off, figure(2), imagesc(weight), colorbar
        c = c, D(N-c,N-c),D(c,c),
        
        %V(:,1:round(N*(1-r))) = 0;
        V_in = single(V*weight*V_t);
        %figure(1), imagesc(D), axis image, figure(2),imagesc(V), axis image, pause
        % a_r is the reconstruction of original a matrix
        a_r = single(zeros(size(a)));
        for i=1:N
            temp = single(zeros(s(1),s(2)));
            for j=1:N
                 temp = temp + V_in(i,j)*a(:,:,j);
            end
            a_r(:,:,i) = temp.*(temp>0);
        end
        
    end
    clock - c0
end 











