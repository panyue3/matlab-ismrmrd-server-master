% This is to do the clustering based on the first three PC of an image
% series.

function x = Cardiac_Image_Pairs(a)
[a_r, V, D] = my_KL_reshape(a,1);

s = size(V);
M = V(:,s(1):-1:s(1)-2); % Use first three eigenimages to find the match
W = [D(256,256),D(255,255),D(254,254)];

for i=1:s(1)-1
    for j=i+1:s(1)-1
        C(i,j) = sum((M(i,:)-M(j,:)).^2.*W);
    end
end


% M = V(:,s(1)-1:-1:s(1)-2); % Use PC 2 and 3
% W = [D(255,255),D(254,254)];% Weighting by the eigenvalue
% 
% C = zeros(s(1),s(1));
% for i=1:s(1)-1
%     for j=i+1:s(1)-1
%         C(i,j) = sum((M(i,:)-M(j,:)).^2.*W);
%     end
% end


C(find(C==0) )= max(C(:));
for i=1:32
%    [x(1,i),x(2,i)] = find( C == max(C(:))  );
    [x(1,i),x(2,i)] = find( C == min(C(:))  );
    C(x(1,i),:) = max(C(:));
    C(:,x(2,i)) = max(C(:));
end
    













