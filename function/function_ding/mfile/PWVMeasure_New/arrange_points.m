function [ ordered_i, ordered_j ] = arrange_points( BW )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

BW_black = BW;
BW_black(:,:)=logical(0);


[i,j]=find(BW);

[temp max_i_index] = max(i);

ordered_i = [i(max_i_index)];
ordered_j = [j(max_i_index)];

%Note: i, j, temp, max_i_index will no longer be needed beyond this point.
clear i; clear j; clear temp; clear max_i_index;

BW(ordered_i(length(ordered_i)), ordered_j(length(ordered_j))) = logical(0);


while(bwarea(BW) > 0)
    
    curr_i = ordered_i(length(ordered_i));
    curr_j = ordered_j(length(ordered_i));
    
    BW_nhood = BW_black;
    BW_nhood(curr_i-1:curr_i+1, curr_j-1:curr_j+1) = logical(1);
   
    BW_intersection = BW & BW_nhood;
    [i,j] = find(BW_intersection);
    
    %note that i and j will be of length 1
    ordered_i = [ordered_i i(1)];
    ordered_j = [ordered_j j(1)];
    
    BW(i(1), j(1)) = logical(0);
    
end

% make sure that the points are arranged 
ordered_i = fliplr(ordered_i);
ordered_j = fliplr(ordered_j);