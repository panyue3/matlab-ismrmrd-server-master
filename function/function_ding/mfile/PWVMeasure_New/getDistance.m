function [distance_of_point] = getDistance(r,c, ordered_i, ordered_j,distances)

% This function finds the distance of the point given by (r,c) along the
% aorta.
% The idea is find the point along the central line closes to (r,c) and
% return its distance
% complex numbers are used for convenience
temp_complex = complex(ordered_i-r, ordered_j-c);
temp_distances = abs(temp_complex);

[c i]= min(temp_distances);

distance_of_point = distances(i);