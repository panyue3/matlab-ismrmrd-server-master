function h=M_I_2(image_1,image_2)
% function h=MI2(image_1,image_2)
%
% Takes a pair of images and returns the mutual information Ixy using joint entropy function JOINT_H.m
% 
% written by http://www.flash.net/~strider2/matlab.htm

a=joint_h(image_1,image_2); % calculating joint histogram for two images
[r,c] = size(a);
% b= a./(r*c); % normalized joint histogram % Yu Ding added: So stupid, this is not the right way to normalize
b = a/sum(a(:));% Yu Ding added this line: This is correct normalization
y_marg=sum(b); %sum of the rows of normalized joint histogram
x_marg=sum(b');%sum of columns of normalized joint histogran

py = find(y_marg > 1/(2^40)); % Find non-zero bins  
px = find(x_marg > 1/(2^40)); % Find non-zero bins  
pxy = find(a > 1/(2^40)); % Find non-zero bins  
Hy = -sum(y_marg(py) .* log2( y_marg(py) ) );   
Hx = -sum(x_marg(px) .* log2( x_marg(px) ) );   
h_xy = -sum(sum(b(pxy).*(log2(b(pxy))))); % joint entropy
h = Hx + Hy - h_xy;% Mutual information

