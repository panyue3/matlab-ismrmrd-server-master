% find_max_average(a,N); a is a 1-D array, N is the number you want to
% average. Find the first N maximum element of the 1-D array and then 
% return the median. 

function a_max = find_max_average(a,N)

a_size = size(a);
a = sort(a);
a_max = median(a(max(a_size)-N:max(a_size)));

