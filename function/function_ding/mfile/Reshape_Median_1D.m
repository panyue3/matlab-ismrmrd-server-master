


function a_1 = Reshape_Median_1D(a_0, width)

s = size(a_0);
a_1 = zeros(s);
if prod(s) ~= max(s)
    disp(['Error! a_0 must be 1-D'])
    return
elseif length(s) > 2
    disp(['Error! a_0 must be 1-D'])
    return
end

if mod(width, 2) == 0
    d = width/2;
else
    d = (width-1)/2;
end

for i = (d+1):(length(a_0)-d)
    a_1(i) = median([a_0(i-d:i+d)]) ; 
end
a_1(1:d) = a_0(d+1);
a_1(length(a_0)-d+1:end) = a_0(length(a_0)-d);
