% Calculate the distance of a curve
% d = curve_distance(x,y), x and y are (1,n) arrays, indicating the distance
% the coordinates of the points of a curve. d is (1,n-1) array, the
% distance between two adjacent points. Sum(d) is the total distance

function d = curve_distance(x,y)

x_d = diff(x); % Difference in x
y_d = diff(y); % Difference in y

d = sqrt(x_d.^2 + y_d.^2); % total distance


