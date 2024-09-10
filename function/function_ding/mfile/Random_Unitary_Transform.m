
% function [a_0, V] = Random_Unitary_Transform(a_0)

function [a_0, V] = Random_Unitary_Transform(a_0)

s = size(a_0);
if length(s)<3,  return, end 

temp = reshape(a_0, prod(s(1:end-1)), s(end));
x = randn(s(end), s(end)*100);
[V, D] = eig(x*x'); 

temp = temp*V;          % Random Unitary Transform 
a_0 = reshape(temp, s);



