function [ handles ] = getVelocityInfo( handles )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

n_aorta_points = length(handles.distances);

velocity_at_each_distance_in_all_images=[];

h = waitbar(0,'Computing Velocity Info. Please wait...', 'name', 'Velocity Info');

len = length(handles.file_names);
for i=1:len
  
    this_file_name = fullfile(handles.vel_file_path, handles.file_names{i,1});
    
    
    I=dicomread(this_file_name);
    I=double(I);
    
    % the next 3 lines do the adjustments for aliasing
    v=handles.alias_adjust;
    if v > 0, I(find(I<v)) = I(find(I<v)) + 4096;end
    if v < 0, I(find(I > 4095+v)) = I(find(find(I > 4095+v))) - 4096;end 
    
    venc = str2num(get(handles.txtVenc, 'String'));
    
    I = (I-2048)/2048;
    I = I*venc;
    
    avg_vel_at_wavefront = [];
    
   
    for count1=1:n_aorta_points
     
        waveFront = handles.points_at_each_distance{count1};
        
        [points_in_this_wavefront junk]=size(waveFront);
        
        vel_at_this_wavefront=[];
        for count2=1:points_in_this_wavefront
            vel_at_this_wavefront = [vel_at_this_wavefront I(waveFront(count2,1),waveFront(count2,2))];
        end
        
        avg_vel_at_wavefront = [avg_vel_at_wavefront mean(vel_at_this_wavefront)];      
       
    end
    
    velocity_at_each_distance_in_all_images=[velocity_at_each_distance_in_all_images; avg_vel_at_wavefront];
    
    waitbar(i/len);
end
close(h);

% check for ascending/descending aorta and  flip the curve about x-axis if
% necessary
for i=1:n_aorta_points
    temp_sign = sign(mean(velocity_at_each_distance_in_all_images(:,i)));
    velocity_at_each_distance_in_all_images(:,i)=temp_sign*velocity_at_each_distance_in_all_images(:,i);
end


handles.velocity_at_each_distance_in_all_images = velocity_at_each_distance_in_all_images;


        
