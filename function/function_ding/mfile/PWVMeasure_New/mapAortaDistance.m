function [ handles ] = mapAortaDistance( handles )

% For each distance value, there will be a set of points  whose distance
% will be same as. This idea is similar to wavefronts. 
% There will be a nx2 matrix denoting each wavefront. There will be 'M'
% such wavefronts, one for each point along central aortic line, ie. one
% for each distance
% In this function, a data-structure is created. This data structure has
% the distances vector and a corresponding cell array of same size. Each
% element of the cell array is a 2xn matrix of the points in the wavefront.

% find the while pixels in aorta and arrange them as Nx2 MATRIX
[i j]=find(handles.original_aorta);
aorta_pixels = [i j];
no_of_aorta_pixels = length(i);

% i and j can now be cleared and used as counters in for loop
clear i; clear j;

% these are the number of points in the central line of aorta
no_of_distance_points = length(handles.distances);

 points_at_each_distance=cell(1,no_of_distance_points);
 
 % initialize the wavefronts as null
 for i=1:no_of_distance_points
     points_at_each_distance{i}=[];
 end
 

 for i=1:no_of_aorta_pixels
     this_distance=getDistance(aorta_pixels(i,1), aorta_pixels(i,2), handles.ordered_i, handles.ordered_j, handles.distances);
     
     index_of_this_distance = find(handles.distances==this_distance);
     
     points_at_each_distance{index_of_this_distance} = [points_at_each_distance{index_of_this_distance}; aorta_pixels(i,1) aorta_pixels(i,2)];
 end
 
 handles.points_at_each_distance = points_at_each_distance;