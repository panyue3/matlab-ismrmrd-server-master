function [t]=getTimeOfMaxJump(vels_at_a_dist)
%possible size of t : -1,1,2,3,4
t=-1; % indicates the value of t was never set. indicates a bad curve that should be rejected
%absolute maximum
[C max_ind]=max(vels_at_a_dist);

start_index = 1;


Data = vels_at_a_dist(start_index:max_ind);

%get all maximas
[M, mi]=peakdet(Data);

% the last element of M will be the maximum. We need to consider only that
% set of elements that are after the last local peak which is less than 20%
% of absolute peak.
for i=length(M)-1:-1:1
    if (M(i)<(0.2*M(length(M))))
        start_index=double(mi(i));
        break;
    end
end

useful_vels_ind = start_index:max_ind;
useful_vels = vels_at_a_dist(useful_vels_ind);


D = diff(useful_vels);

[C I] = max(D);
max_diff_index = I;

if(C<0)
    return;
end


jump_points = [C I];

next_higher_ind = I + 1;
next_lower_ind = I -1;

for i=1:3
    
    if (next_lower_ind>=1)& (next_higher_ind<=length(D))
        if((D(next_higher_ind)>D(next_lower_ind)) & (D(next_higher_ind)>0))
            jump_points = [jump_points; D(next_higher_ind), next_higher_ind];
            next_higher_ind = next_higher_ind + 1;
            next_lower_ind = next_lower_ind;
        elseif ((D(next_higher_ind)<D(next_lower_ind)) & (D(next_lower_ind)>0))
            jump_points = [jump_points; D(next_lower_ind), next_lower_ind];
            next_higher_ind = next_higher_ind;
            next_lower_ind = next_lower_ind - 1;
        end
    elseif (next_lower_ind<1)& (next_higher_ind<=length(D))
            jump_points = [jump_points; D(next_higher_ind), next_higher_ind];
            next_higher_ind = next_higher_ind + 1;
            next_lower_ind = next_lower_ind;            
    elseif ((next_higher_ind>length(D)) & (next_lower_ind>=1))
            jump_points = [jump_points; D(next_lower_ind), next_lower_ind];
            next_higher_ind = next_higher_ind;
            next_lower_ind = next_lower_ind - 1;
                
    end
    
end

diff_indices = sort(jump_points(:,2));

% change in logic
% if 3 or 4 points were selected and if all points are on left of maxima,
% then check for the point immediately right of maxima. If it is negative,
% we ignore the curve. Else, we take the point to right.
% If instead, the points are all on right of maxima, and the point on left
% is negative, we take the maxima as the point. Else take the point to
% left.
if(max_diff_index == max(diff_indices) )
    if (length(D)>max_diff_index) & (D(max_diff_index+1)<0)
        return;
    elseif (length(D)>max_diff_index)
        diff_indices = min(diff_indices):max(diff_indices)+1;
    end
    
elseif (max_diff_index == min(diff_indices) )
    if ((1<max_diff_index) & (D(max_diff_index-1)<0))|(1==max_diff_index)
        t=start_index-1 + max_diff_index;
        return;
    elseif (1<max_diff_index)
        diff_indices = min(diff_indices)-1:max(diff_indices);
    end           
       
end

max_jump_indices = double(min(diff_indices):max(diff_indices)+1);
max_jump_indices_in_original_plot = start_index - 1 + max_jump_indices;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% upto this point, we have only found the indices for maximum jump
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_indices = max_jump_indices_in_original_plot;
diff_indices(1)=[]; % note that when we take difference, its size is one less. We can either remove the last or first element. Here we remove the first.
D = diff(vels_at_a_dist(max_jump_indices_in_original_plot)); % this is FIRST DIFFERENCE

% Henceforth, we will work only with D and diff_indices
switch length(D)
  case {1 ,2}
    [C I]=max(D);
    t = diff_indices(I);
  otherwise
    p=polyfit(double(diff_indices'), D, 2);  
    k = polyder(p);
    t = -k(2)/k(1);
end
