% This to get the g-factor map
% [g_map, x,y] = g_Factor_Map(a, P);
% a is the cine data
% P is the number of pairs you like to use.

function [g_map,x,y] = g_Factor_Map(a, P);

s = size(a);
N = s(3);
b = (reshape(a, [s(1)*s(2),s(3)] )); clear a
t_mean = mean(b,1);
b_mean = ones(s(1)*s(2),1)*t_mean;
b = b - b_mean; clear b_mean
b_std = std(b,0,1); % Standard deviation of each image

A_0 = b'*b./(b_std'*b_std)/s(1)/s(2); %Normalized A

for i=1:N, A_0(i,i)=0; end % suppress autocorrelation.
L = length(A_0(:)); % Total number of coefficients
Y = sort(A_0(:),'descend'); % Sort all the autocorrelation coefficients
[x,y] = find(A_0>=Y(P*2)); % Take 64 pairs, each pair twice
d = zeros(s(1),s(2),length(x));
% for i=1:length(x)
%     c = (b(:,x(i)) - b(:,y(i)));
%     d(:,:,i)= reshape( c , [s(1),s(2)])/sqrt(2) ;
%     %i = i,imagesc(d(:,:,i)), colorbar, title(num2str(i)), pause,
% end

d= reshape( (b(:,x(:)) - b(:,y(:))) , [s(1),s(2),length(x)])/sqrt(2) ;

g_map = sqrt(sum(d.*d,3)/2/(P-1));





