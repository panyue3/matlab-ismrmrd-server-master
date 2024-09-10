function h=joint_h(image_1,image_2)
% function h=joint_h(image_1,image_2)
%
% takes a pair of images of equal size and returns the 2d joint histogram.
% used for MI calculation
% 
% written by http://www.flash.net/~strider2/matlab.htm

% The following two lines are added by Yu Ding, 2007/11/29

N = 16;

image_1 = (floor((N-0.001)*(image_1 - min(image_1(:)))/( max(image_1(:)) - min(image_1(:)) )));
image_2 = (floor((N-0.001)*(image_2 - min(image_2(:)))/( max(image_2(:)) - min(image_2(:)) )));
%max(image_1(:)), min(image_1(:)), max(image_2(:)), min(image_2(:)), 

rows=size(image_1,1);
cols=size(image_1,2);

h=zeros(N,N);

% for i=1:rows;    %  col 
%   for j=1:cols;   %   rows
%     h(image_1(i,j)+1,image_2(i,j)+1)= h(image_1(i,j)+1,image_2(i,j)+1)+1;
%   end
% end

% The following is another algorithm to calculate the histogram

for i=1:N % image_1 intensity bin # i
    tmp = 0;
    tmp = find(image_1==i);
    for j = 1:N
        h(i, j) = sum(image_2(tmp) == j);
    end
end


