%
% b = diff2(a,d)
%

function [kxx,kyy] = diff2(a,d);
'differentiating ...'
[l,m] =size(a);

ky = zeros(l,m);kx=zeros(l,m); b = 0; i = 0; j = 0 ;

D = zeros(l,m);
for i = 2 :l-1, D(i,i)=-2;D(i,i-1) = 1; D(i,i+1) = 1; end ;

for i = 2 : l-1,
        
        ky(:,i) = D*a(:,i)/(d*d);
        kx(i,:) = (D*a(i,:)')'/(d*d);
       
end 
'differentiate finish'
kxx = kx(2:l-1,2:m-1);
kyy = ky(2:l-1,2:m-1); 
