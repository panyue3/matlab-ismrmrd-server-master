function [ dist, t_f, error_point_indices ] = getPWVPoints1( handles )


% initialize the variables because me may return to the calling function
% without populating some or all of them
error_point_indices =[];
dist=[];
t_f=[];


d=handles.distances;

t=[];
for i=1:length(d)
   t=[t getTimeOfMaxJump(handles.velocity_at_each_distance_in_all_images(:,i))]; 
end


% t=-1 indicates bad curve according to the function getTimeOfMaxJump.
error_point_indices = find(t==-1);

%if there are error points, return them to the calling function. The
%calling function will remove them and call this function again
if(length(error_point_indices)>0)
    return;
end


%%
dist = handles.distances*0.1;% distances in cms and not mm

triggerTime = handles.times(2)-handles.times(1);
t_f = t*triggerTime/1000; 


