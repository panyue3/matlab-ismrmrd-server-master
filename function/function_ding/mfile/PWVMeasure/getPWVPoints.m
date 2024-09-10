function [ dist, t_f, error_point_indices ] = getPWVPoints( handles )

% This function uses Ding's code

% initialize the variables because me may return to the calling function
% without populating some or all of them
error_point_indices =[];
dist=[];
t_f=[];

mean_v = handles.velocity_at_each_distance_in_all_images;
d=handles.distances;

%% This line onwards is Ding's code
[s_1,s_2] = size(mean_v);
max_v = max(mean_v,[],1);
max_v_0 = ones(s_1,1)*max_v;
mean_v = mean_v./max_v_0;

[x_t,y_t] = Wave_Front(mean_v(:,1),0.2,0.8);
L = length(x_t);
j = 1;
d_f(1) = 0; % distance from first point.
d_t(1) = 0; % Temp value of distance
%[x(1:L,j),y(1:L,j)] = Wave_Front_new(mean_v(:,1),0.2,0.8);

%x(1) = Wave_Front_jump(mean_v(:,1));


for i=1:s_2    
    
    try
        x(i) = Wave_Front_jump(mean_v(:,i));
    catch
        error_point_indices = [error_point_indices i];
    end

end

%if there are error points, return them to the calling function. The
%calling function will remove them and call this function again
if(length(error_point_indices)>0)
    return;
end

t_f(1) = 1;
%for i = 1:j-1,     t_f(i+1) = t_f(i)+D(i); end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear Fit works better than regression because of the offset. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[t_f',d_f']
i_m = length(x); 
i = 1:i_m; 
t_f = x; % Use the wavefront center data.

triggerTime = handles.times(2)-handles.times(1);
t_f = t_f*triggerTime/1000; 
t_max = max(t_f(2:end));
t_min = min(t_f(2:end));

    %%This is commented out temporarily
% if prod(bad_data-1) i = [1:i_m];
% else i = [2:i_m];
% end % I do not have to remove bad data here except checking if 1 is a bad data, they have all been removed.

%%
dist = handles.distances*0.1;% distances in cms and not mm
