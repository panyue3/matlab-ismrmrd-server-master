% This is my KL transform function, there are two inputs: the 3-D data
% array and the percentage eign images you want to keep [V,D] = KL_Eigen(a), a is
% a 3-D array, the third dimension is the frame number,  V is the eigen
% vector matrix, D is the eigen value matrix
% 

function [V,D] = KL_Eigen(a);

%a = single(a);
s = size(a);
N = s(3);
if length(s) ~=3,
    'Input array is not a 3-D array!'
else
%     if r>1|r<=0
%         'The ratio must belong to (0 1]'
%     else
        %clock,
        b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
        t_mean = mean(b,1); size(t_mean);
        b_mean = ones(s(1)*s(2),1)*t_mean;
        b = b - b_mean; %clear b_mean
%        b_std = std(b,0,1);
        A = (b'*b)/(s(1)*s(2)); clear b % This is the covariance matrix % clear b; % Imagesc(A), pause,
        
        %clock,
        [V,D] = (eig(A)); % This is to diagonalize the covariance matrix
%         V = single(V);
%         D = single(D);
        %clock,
        % Try to reconstruct the eigen images. The first one (No.20) should be the mean
%         I = single(zeros(size(a)));
%         for i=1:N
%             temp = single(zeros(s(1),s(2)));
%             for j=1:N
%                 temp = temp + V(j,i)*a(:,:,j);
%             end
%             I(:,:,i) = temp;
%         end
%         %clock,
%         % V_in is the inverse matrix of V (orthogonal matrix)
%         V_in = single(V');
% 
%         % a_r is the reconstruction of original a matrix
%         a_r = single(zeros(size(a)));
%         for i=1:N
%             temp = single(zeros(s(1),s(2)));
%             for j=N-round(N*r)+1:N
%                  temp = temp + V_in(j,i)*I(:,:,j);
%             end
%             a_r(:,:,i) = temp;
%         end
        
%     end
    
end











