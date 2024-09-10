function [ is_max_two_neighbor ] = max_two_neigh( BW )
%UNTITLED1 Summary of this function goes here
%  Returns true if each pixel in the binary image has at most 2 neighbor
% else returns false.
[i,j]=find(BW);

is_max_two_neighbor = true;

noOfNonZeroPoints = length(i);

for count=1:noOfNonZeroPoints
    temp_i = i(count);
    temp_j = j(count);
    
    neighbor_hood = BW((temp_i-1):(temp_i+1), (temp_j-1):(temp_j+1));
    
    sum_of_nhood = sum(sum(neighbor_hood));
    
    if(round(sum_of_nhood) > 3)
        is_max_two_neighbor = false;
        break;
    end
        
end
