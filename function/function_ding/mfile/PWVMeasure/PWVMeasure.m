function varargout = PWVMeasure(varargin)
% PWVMEASURE M-file for PWVMeasure.fig
%      PWVMEASURE, by itself, creates a new PWVMEASURE or raises the existing
%      singleton*.
%
%      H = PWVMEASURE returns the handle to a new PWVMEASURE or the handle to
%      the existing singleton*.
%
%      PWVMEASURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PWVMEASURE.M with the given input arguments.
%
%      PWVMEASURE('Property','Value',...) creates a new PWVMEASURE or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PWVMeasure_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PWVMeasure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PWVMeasure

% Last Modified by GUIDE v2.5 03-May-2007 18:33:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PWVMeasure_OpeningFcn, ...
                   'gui_OutputFcn',  @PWVMeasure_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PWVMeasure is made visible.
function PWVMeasure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PWVMeasure (see VARARGIN)

% Choose default command line output for PWVMeasure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PWVMeasure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PWVMeasure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mnuLoad_Callback(hObject, eventdata, handles)
% hObject    handle to mnuLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[fname,pname] = uigetfile('*.*','Select any one file from the Image series');
        
% in case user presses cancel
if (isequal(fname,0)|isequal(pname,0))
    return;
end;

handles.ImageNumber = 1; % initially,keep it one.
handles.isOriginalImageDisplayed = true; % this attribute helps to switch between binary and original Image

set(handles.txtAliasingAdjust, 'String', num2str(0));
handles.alias_adjust = str2num(get(handles.txtAliasingAdjust, 'String')); % as the image loads, this will be set to zero


%enableWanted([handles.panelImageType handles.chkPlayMovie handles.cmdPreviousImage handles.cmdNextImage handles.cmdSelectPoint]);
enableWanted([handles.panelImageDisplay]);
disableUnwanted([handles.panelAortaSeparation, handles.panelStats, handles.panelImageSwitch]);

base_path='';

% the while loop constructs the path
while (true)
    [current_token, remain] = strtok(pname, filesep);
        
    %break out of while loop when all tokens have been collected
    if (strcmp(remain, filesep))
        break;
    end

    base_path = strcat(strcat(base_path, current_token),filesep);
    
    pname = remain;
end

handles.mag_file_path=strcat(strcat(base_path, 'magnitude'), filesep);
handles.vel_file_path=strcat(strcat(base_path, 'velocity'), filesep);

% get the names of  files and store them in the handles structure
dicom_files=dir(fullfile(handles.mag_file_path, '*.*')); % note- magnitude and velocity files will have same name
handles.file_names=massageFileNames(dicom_files);

guidata(hObject,handles);

[times max_mag_intensities max_vel_intensities]=getTimeAndMaxValues(handles);

handles.times=times;
handles.max_mag_intensity = max(max_mag_intensities);
handles.max_vel_intensity = max(max_vel_intensities);

[x,y,diagonal] = getPixelDimensions(handles);
handles.xpixel = x;
handles.ypixel = y;
handles.diagpixel = diagonal;

guidata(hObject,handles);

% sort the files based on the trigger time
handles = sortByTriggerTime( handles);
guidata(hObject,handles);

handles = showImage(hObject, handles);

guidata(hObject,handles);


% --------------------------------------------------------------------
function mnuFile_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function panelImageType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to panelImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = showImage(hObject, handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
% --- Executes on button press in cmdNextImage.
function cmdNextImage_Callback(hObject, eventdata, handles)
% hObject    handle to cmdNextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = nextImage(hObject, handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
% --- Executes on button press in cmdPreviousImage.
function cmdPreviousImage_Callback(hObject, eventdata, handles)
% hObject    handle to cmdPreviousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
max_img_num = length(handles.times);

if (handles.ImageNumber == 1)
    handles.ImageNumber = max_img_num;
else
    handles.ImageNumber = handles.ImageNumber - 1;
end

handles = showImage(hObject, handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
% --- Executes on button press in chkPlayMovie.
function chkPlayMovie_Callback(hObject, eventdata, handles)
% hObject    handle to chkPlayMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkPlayMovie
while(get(hObject,'Value'))
    handles = nextImage(hObject, handles);
    guidata(hObject,handles);
end



% --------------------------------------------------------------------
% --- Executes on slider movement.
function sliderThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to sliderThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
threshold = get(hObject,'Value');
thresholdMessage = ['Threshold = ' num2str(threshold) '%'];
set(handles.lblThreshold, 'String', thresholdMessage);

max_binary_pixel_val = max(max(handles.original_masked_image));
pixel_threshold = max_binary_pixel_val*threshold/100;

handles.binary_image = (handles.original_masked_image > pixel_threshold);
handles.binary_image = bwmorph(handles.binary_image, 'clean');
handles.binary_image = bwmorph(handles.binary_image, 'erode');
handles.binary_image = bwmorph(handles.binary_image, 'clean');
handles.binary_image = bwmorph(handles.binary_image, 'dilate');
guidata(hObject,handles);

axes(handles.mainFigure);
imshow(handles.binary_image);

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function sliderThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --------------------------------------------------------------------

% --- Executes on button press in cmdSelectPoint.
function cmdSelectPoint_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSelectPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isVelocitySelected = get(handles.rdbVelocity, 'Value');
if(~isVelocitySelected)
    msgbox('Please select the velocity image first', 'Incorrect Image', 'warn');
       
else
    [y, x, button] = ginput(1);
    
    %the user has the option of not entering any point by right or middle
    %clicking
    if(button ~= 1)
        return;
    end
    
    x=round(x); y=round(y);
    
    handles.binary_image = corr_filter(handles,x, y);
    handles.original_masked_image = handles.binary_image; % this will be used as a backup when we change the binary_image using slider
    handles.isOriginalImageDisplayed = false;    
    guidata(hObject,handles);
    
    axes(handles.mainFigure);
    imshow(handles.binary_image);
    
    %disableUnwanted([handles.panelImageType handles.chkPlayMovie handles.cmdPreviousImage handles.cmdNextImage handles.cmdSelectPoint]);
    disableUnwanted([handles.panelImageDisplay]);
    %enableWanted([handles.sliderThreshold handles.lblThreshold]);
    enableWanted([handles.panelAortaSeparation handles.panelStats handles.panelImageSwitch]);
    
    set(handles.sliderThreshold, 'Value', 0);
    thresholdMessage = ['Threshold = 0%'];
    set(handles.lblThreshold, 'String', thresholdMessage);
end

% --------------------------------------------------------------------


% --- Executes on button press in cmdSwitchImage.
function cmdSwitchImage_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSwitchImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.mainFigure);

if(handles.isOriginalImageDisplayed)
    handles.isOriginalImageDisplayed = false;
    imshow(handles.binary_image);
    
    disableUnwanted([handles.panelImageDisplay]);
    enableWanted([handles.panelAortaSeparation handles.panelStats]);
    
    %disableUnwanted([handles.panelImageType handles.chkPlayMovie handles.cmdPreviousImage handles.cmdNextImage handles.cmdSelectPoint]);
    %enableWanted([handles.sliderThreshold handles.lblThreshold]);
else
    handles.isOriginalImageDisplayed = true;
    imshow(handles.I);
    
    enableWanted([handles.panelImageDisplay]);
    disableUnwanted([handles.panelAortaSeparation handles.panelStats]);
    
    %enableWanted([handles.panelImageType handles.chkPlayMovie handles.cmdPreviousImage handles.cmdNextImage handles.cmdSelectPoint]);
    %disableUnwanted([handles.sliderThreshold handles.lblThreshold]);
end
guidata(hObject,handles);
   
% --------------------------------------------------------------------

% --- Executes on button press in cmdRemoveRegion.
function cmdRemoveRegion_Callback(hObject, eventdata, handles)
% hObject    handle to cmdRemoveRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[y, x, button] = ginput(1);

    
while(button == 1)
    x=round(x); y=round(y);
    
        
    % for the following step, remember that we need to get rid of the
    % selected region. Now, a binary image is a logical operand, with 1's and 0's. Hence we
    % use this fact to set to 0's the pixels in the selected region. To
    % acheive this, consider a truth table between input
    % A(handles.binary_image) and input B (BW2).     
    if(get(handles.rdbRemoveRegion, 'Value'))
        BW2 = bwselect(handles.binary_image,y,x,4);
        handles.binary_image = ((~BW2) & handles.binary_image);    
    else
        BW2 = (bwselect(~(handles.binary_image),y,x,4));
        handles.binary_image = (BW2 | handles.binary_image);
    end
    
    % before shrinking/spurring, save the aorta
    handles.original_aorta = handles.binary_image;
    
    guidata(hObject,handles);
    
    axes(handles.mainFigure);
    imshow(handles.binary_image);
    
    [y, x, button] = ginput(1);
end
   
% --------------------------------------------------------------------

% --- Executes on button press in cmdPolygonAddRemove.
function cmdPolygonAddRemove_Callback(hObject, eventdata, handles)
% hObject    handle to cmdPolygonAddRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BW2 = roipoly(handles.binary_image);
 
    
if(get(handles.rdbRemoveRegion, 'Value'))
    handles.binary_image = ((~BW2) & handles.binary_image);    
else
    handles.binary_image = (BW2 | handles.binary_image);
end

% before shrinking/spurring, save the aorta
handles.original_aorta = handles.binary_image;

axes(handles.mainFigure);
imshow(handles.binary_image);
guidata(hObject,handles);

% --------------------------------------------------------------------

% --- Executes on button press in cmdShrink.
function cmdShrink_Callback(hObject, eventdata, handles)
% hObject    handle to cmdShrink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% added on march 20, to enable undo of shrink
handles.binary_image = handles.original_aorta;

handles.binary_image = bwmorph(handles.binary_image,'thin', Inf);

guidata(hObject,handles);

axes(handles.mainFigure);
imshow(handles.binary_image);

% --------------------------------------------------------------------
% --- Executes on button press in cmdSpur.
function cmdSpur_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSpur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

while(true)
    if(max_two_neigh(handles.binary_image))
        break;
    else
        handles.binary_image = bwmorph(handles.binary_image,'spur');
        guidata(hObject,handles);
        axes(handles.mainFigure);
        imshow(handles.binary_image);
    end
end

% save the center line
handles.aorta_central_line = handles.binary_image;

%% the rest of this function deals with ordering the points and finding
%% distances
[ordered_i, ordered_j] = arrange_points(handles.binary_image);
handles.ordered_i = ordered_i;
handles.ordered_j = ordered_j;
guidata(hObject,handles);

% get the pixel dimensions, which will be used to find distances
[pixel_x_length, pixel_y_length, pixel_diag_length]=getPixelDimensions(handles);

%initiate a zeros matrix for distances. this automatically sets the
%distance of first pixel as zero.
distances=zeros(1, length(ordered_i));

for count= 2:length(ordered_i)
    
    % getting the previous pixel coordinates
    prev_i = handles.ordered_i(count-1);
    prev_j = handles.ordered_j(count-1);
    
    % current pixel coordinates
    curr_i = handles.ordered_i(count);
    curr_j = handles.ordered_j(count);
    
    % calculate distance depending on whether the current pixel is changing
    % in x, y or both directions
    % NOTE: x and y directions will be respectively j (columns) and i (rows)
    if (prev_i == curr_i)
        % the row coordinates are same for both pixels. Only the columns (x
        % dimension) change
        distances(count)=distances(count-1)+ pixel_x_length;
    elseif (prev_j == curr_j)
        distances(count)=distances(count-1)+ pixel_y_length;    
    else
        distances(count)=distances(count-1)+ pixel_diag_length;
    end     
    
end

handles.distances=distances;
handles.all_distances = distances; % this extra array is used to store distances because handles.distances will change in size as outliers are removed. However, to calculate the slope of curve, we need original set of distances
guidata(hObject,handles);



%%%%%%%%%%%%%%%%%displaying the image
%{
BW = handles.binary_image;
BW(:,:)= logical(0);
axes(handles.mainFigure);
imshow(BW);

for count=1:length(ordered_i)
    BW_black(ordered_i(count), ordered_j(count))=logical(1);
    axes(handles.mainFigure);
    imshow(BW_black);
end
%}


% --------------------------------------------------------------------
% --- Executes on button press in cmdUndoShrinkSpur.
function cmdUndoShrinkSpur_Callback(hObject, eventdata, handles)
% hObject    handle to cmdUndoShrinkSpur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.binary_image = handles.original_aorta;

guidata(hObject,handles);

axes(handles.mainFigure);
imshow(handles.binary_image);


% --------------------------------------------------------------------

% --- Executes on button press in cmdGenerateVelData.
function cmdGenerateVelData_Callback(hObject, eventdata, handles)
% hObject    handle to cmdGenerateVelData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=mapAortaDistance(handles);
guidata(hObject,handles);

handles = getVelocityInfo(handles);
guidata(hObject,handles);



% --------------------------------------------------------------------
function txtVenc_Callback(hObject, eventdata, handles)
% hObject    handle to txtVenc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtVenc as text
%        str2double(get(hObject,'String')) returns contents of txtVenc as a double
% --------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function txtVenc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtVenc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------


% --- Executes on button press in cmdArchBounds.
function cmdArchBounds_Callback(hObject, eventdata, handles)
% hObject    handle to cmdArchBounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%move the slider slightly to get the arch bounds
% axes(handles.mainFigure);
% imshow(handles.original_aorta);


[y, x, button] = ginput(2);

d1 = getDistance(x(1),y(1), handles.ordered_i, handles.ordered_j, handles.distances);
d2 = getDistance(x(2),y(2), handles.ordered_i, handles.ordered_j, handles.distances);

index_d1 = find(handles.distances==d1);
index_d2 = find(handles.distances==d2);

handles.velocity_at_each_distance_in_all_images(:,index_d1:index_d2)=[];
handles.distances(index_d1:index_d2)=[];
guidata(hObject,handles);




% --------------------------------------------------------------------
% --- Executes on button press in cmdAnalyseCurves.
function cmdAnalyseCurves_Callback(hObject, eventdata, handles)
% hObject    handle to cmdAnalyseCurves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curve_index = 1;
guidata(hObject,handles);

axes(handles.mainFigure);
plot(handles.times, handles.velocity_at_each_distance_in_all_images(:,handles.curve_index), ':');
xlabel('Time (Trigger) in ms'); ylabel('Velocity');

set(handles.txtDistance, 'String', num2str(round(handles.distances(handles.curve_index))));

% --------------------------------------------------------------------
function txtDistance_Callback(hObject, eventdata, handles)
% hObject    handle to txtDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDistance as text
%        str2double(get(hObject,'String')) returns contents of txtDistance as a double

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function txtDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
% --- Executes on button press in cmdRejectCurve.
function cmdRejectCurve_Callback(hObject, eventdata, handles)
% hObject    handle to cmdRejectCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.velocity_at_each_distance_in_all_images(:,handles.curve_index)=[];
handles.distances(handles.curve_index)=[];
guidata(hObject,handles);

% if the rejected curve was the last one, display the first curve; else
% display the curve of same index, which will be the next image.
[junk, num_of_distances]=size(handles.velocity_at_each_distance_in_all_images);

if (handles.curve_index > num_of_distances)
    handles.curve_index = 1;
end

axes(handles.mainFigure);
plot(handles.times, handles.velocity_at_each_distance_in_all_images(:,handles.curve_index), ':');
xlabel('Time (Trigger) in ms'); ylabel('Velocity');

set(handles.txtDistance, 'String', num2str(round(handles.distances(handles.curve_index))));
guidata(hObject,handles);


% --------------------------------------------------------------------
% --- Executes on button press in cmdNextCurve.
function cmdNextCurve_Callback(hObject, eventdata, handles)
% hObject    handle to cmdNextCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curve_index = handles.curve_index + 1;

[junk, num_of_distances]=size(handles.velocity_at_each_distance_in_all_images);

if (handles.curve_index > num_of_distances)
    handles.curve_index = 1;
end

axes(handles.mainFigure);
plot(handles.times, handles.velocity_at_each_distance_in_all_images(:,handles.curve_index), ':');
xlabel('Time (Trigger) in ms'); ylabel('Velocity');

set(handles.txtDistance, 'String', num2str(round(handles.distances(handles.curve_index))));
guidata(hObject,handles);

% --------------------------------------------------------------------
% --- Executes on button press in cmdPreviousCurve.
function cmdPreviousCurve_Callback(hObject, eventdata, handles)
% hObject    handle to cmdPreviousCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.curve_index = handles.curve_index - 1;

[junk, num_of_distances]=size(handles.velocity_at_each_distance_in_all_images);

if (handles.curve_index < 1)
    handles.curve_index = num_of_distances;
end

axes(handles.mainFigure);
plot(handles.times, handles.velocity_at_each_distance_in_all_images(:,handles.curve_index), ':');
xlabel('Time (Trigger) in ms'); ylabel('Velocity');

set(handles.txtDistance, 'String', num2str(round(handles.distances(handles.curve_index))));
guidata(hObject,handles);
% --------------------------------------------------------------------
% --- Executes on button press in cmdPlotPWV.
function cmdPlotPWV_Callback(hObject, eventdata, handles)
% hObject    handle to cmdPlotPWV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if there are some error points, then wave_dist and wave_time will be
% null, but error_point_indices will be non-null
[wave_dist, wave_time, error_point_indices]=getPWVPoints1(handles);
num_errors=length(error_point_indices);


if(num_errors>0) 
    msgbox('Some curves were rejected. Please see MATLAB command prompt.','Bad Curve','warn');
    disp 'The curves with following indices were removed'
    disp (error_point_indices);
    % remove the data pertinent to all the error points
    handles.velocity_at_each_distance_in_all_images(:,error_point_indices)=[];
    handles.distances(error_point_indices)=[];
    guidata(hObject,handles);        
end

% recompute the PWVPoints
[wave_dist, wave_time, error_point_indices]=getPWVPoints1(handles);


% save the distance and time data for future use in removing outliers
handles.wave_dist = wave_dist;
handles.wave_time = wave_time;
guidata(hObject,handles);

plotPWVCurve(handles, 'ui');
%R1=corrcoef(t_f,dist)

% --------------------------------------------------------------------

% --- Executes on button press in cmdImprovePlot.
function cmdImprovePlot_Callback(hObject, eventdata, handles)
% hObject    handle to cmdImprovePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.mainFigure);

[x,y, button] = ginput(1);

    
while(button == 1)
    
    %the next line makes a vector of complex numbers to calculate the
    %distance of the selected point from each point. In the step after
    %that, we try to find the minimum distance
    %Note that there is a division by the maximum value in each axes. This
    %is to eliminate the errors caused by different scales of x and y axes.
    temp_for_dist = abs(complex((handles.wave_time-x)/max(handles.wave_time),(handles.wave_dist-y)/max(handles.wave_dist))); 
    
    [junk, outlier_index] = min(temp_for_dist);
    
    handles.wave_time(outlier_index)=[];
    handles.wave_dist(outlier_index)=[];
    handles.velocity_at_each_distance_in_all_images(:,outlier_index)=[];
    
    guidata(hObject,handles);

    plotPWVCurve(handles, 'ui');
    
    [x,y, button] = ginput(1);
end

% --------------------------------------------------------------------
function mnuPrint_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPrint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuPrintFigure_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPrintFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotPWVCurve(handles, 'separate');



% --------------------------------------------------------------------
function mnuFileSave_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFileSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuFileSavePWVData_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFileSavePWVData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_file_name = inputdlg('Enter file name','File name',1,cellstr('default_file_name'));

% check if the user clicked Cancel
filelength=size(data_file_name);
if(filelength(1) == 0)
    return;
end

PWVData.velocity_matrix = handles.velocity_at_each_distance_in_all_images;
PWVData.notes ='The velocity matrix is MxN where M is the number of images and N is the number of points along Aorta. wave_dist and wave_time are used for plotting PWV. all_distances, ordered_i, ordered_j, imageSize are used for pressure. Ordered_i and ordered_j represent the points along central aorta line; all_distances represent distances along the center line. ImageSize may be of help in doing the polynomial fit of center line';
PWVData.wave_dist = handles.wave_dist;
PWVData.wave_time = handles.wave_time;
PWVData.all_distances = handles.all_distances;
PWVData.ordered_i = handles.ordered_i;
PWVData.ordered_j = handles.ordered_j;
PWVData.imageSize = size(handles.aorta_central_line);
PWVData.vel_dicom_data=dicominfo([handles.vel_file_path , handles.file_names{1,1}]);

save(char(data_file_name), 'PWVData');
% --------------------------------------------------------------------
%*********************************************************************
%For better readibility, all user defined non-call back functions between
%these messages
%*********************************************************************
% --------------------------------------------------------------------
function [] = plotPWVCurve(handles, which_axes)

if(strcmpi(which_axes, 'ui'))
    axes(handles.mainFigure);
else
    figure;
end

plot(handles.wave_time, handles.wave_dist, '*');
hold on;

% get the average graph
p = polyfit(handles.wave_time,handles.wave_dist,1);
new_dist = p(1)*handles.wave_time + p(2);
plot(handles.wave_time, new_dist);
hold off;

%calculate regression
SSE = sum((handles.wave_dist-new_dist).^2);
SSTO= sum((handles.wave_dist-mean(handles.wave_dist)).^2);
R=sqrt(1-(SSE/SSTO));

set(gca, 'FontSize', 14 );
title(['Pulse wave velocity = ' num2str(p(1)) ' cm/s.   R=' num2str(R)], 'FontSize', 20);
xlabel('Time in sec', 'FontSize', 20);ylabel('Distance along aorta in cms', 'FontSize', 20);

% --------------------------------------------------------------------
function [file_names]=massageFileNames(dicom_files)

len=length(dicom_files);

%this variable keeps count of blank file names
blank_count=0;

for i=1:len    
    if(strcmpi(dicom_files(i).name,'.') | strcmpi(dicom_files(i).name, '..'))
        blank_count = blank_count + 1;
    else
        file_names{i-blank_count, 1}=dicom_files(i).name;
    end
end
% --------------------------------------------------------------------
% get the time-value of each image
function [times, max_mag_intensities, max_vel_intensities]=getTimeAndMaxValues(handles);
times=[];
[len temp] = size(handles.file_names);

max_mag_intensities=[];
max_vel_intensities=[];

h = waitbar(0,'Loading Dicom files info. Please wait...', 'name', 'Load');
for i=1:len
    
    tempImage = getImage(fullfile(handles.vel_file_path, handles.file_names{i,1}), 'vel', handles.alias_adjust);
    max_vel_intensities = [max_vel_intensities max(max(tempImage))];
    
    tempImage = getImage(fullfile(handles.mag_file_path, handles.file_names{i,1}), 'mag', handles.alias_adjust);
    max_mag_intensities = [max_mag_intensities max(max(tempImage))];
    
    % Note that you must take the trigger time from Velocity files. This
    % change was done on August 9th, 2007
    temp=dicominfo([handles.vel_file_path , handles.file_names{i,1}]);
    times=[times;(temp.TriggerTime)];

    waitbar(i/len);
end
close(h);

times=times';
% --------------------------------------------------------------------
%get dimensions of pixel from dicom info
function [x,y,diagonal] = getPixelDimensions(handles);
info = dicominfo(fullfile(handles.vel_file_path, handles.file_names{1,1}));
x = info.PixelSpacing(1,1);
y = info.PixelSpacing(2,1);
diagonal = sqrt((x*x) + (y*y));
% --------------------------------------------------------------------
%this is called by next and previous image buttons
function [handles] = showImage(hObject, handles);

axes(handles.mainFigure);

if(get(handles.rdbMagnitude, 'Value'))
    I = getImage(fullfile(handles.mag_file_path, handles.file_names{handles.ImageNumber,1}), 'mag', handles.alias_adjust, handles.max_mag_intensity);
else
    I = getImage(fullfile(handles.vel_file_path, handles.file_names{handles.ImageNumber,1}), 'vel', handles.alias_adjust, handles.max_vel_intensity);
    
end

handles.I = I;

%guidata(hObject,handles); %this line is useless in user-defined functions
imshow(handles.I);
imageTime = handles.times(handles.ImageNumber);

title(['Image ' num2str(handles.ImageNumber) ' of ' num2str(length(handles.times)) '. Trigger time of this image = ' num2str(imageTime) 'msec']);

% --------------------------------------------------------------------
function [handles] = nextImage(hObject, handles)
max_img_num = length(handles.times);

if (handles.ImageNumber == max_img_num)
    handles.ImageNumber = 1;
else
    handles.ImageNumber = handles.ImageNumber + 1;
end

%guidata(hObject,handles); %this line is useless in user-defined functions

handles = showImage(hObject, handles);

% --------------------------------------------------------------------
% this function is called by a radio button to disable the controls not
% required for the operation
function disableUnwanted(off)
set(off, 'visible', 'off');

% --------------------------------------------------------------------
% this function is called by a radio button to enable the controls 
% required for the operation
function enableWanted(on)
set(on, 'visible', 'on');
% --------------------------------------------------------------------


% --------------------------------------------------------------------
%*********************************************************************
%For better readibility, all user defined non-call back functions between
%these messages
%*********************************************************************
% --------------------------------------------------------------------


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.binary_image = bwmorph(handles.binary_image, 'dilate', 6);
% %handles.binary_image = bwmorph(handles.binary_image, 'bridge', 4);
% %guidata(hObject,handles);
% 
% axes(handles.mainFigure);
% imshow(handles.binary_image);
handles=mapAortaDistance(handles);
guidata(hObject,handles);

% display the animation 
BW = handles.binary_image;
BW(:,:)= logical(0);
axes(handles.mainFigure);
imshow(BW);

% ingore the first and the last points/wavefronts
for count=2:2:length(handles.points_at_each_distance)-1
    
    
    [no_points_in_wavefront, temp] = size(handles.points_at_each_distance{count});
    
    for count2=1:no_points_in_wavefront
        BW(handles.points_at_each_distance{count}(count2, 1), handles.points_at_each_distance{count}(count2, 2))=logical(1);
        axes(handles.mainFigure);
        imshow(BW);
    end
end

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.mainFigure);
tempBW =  handles.original_aorta & (~handles.aorta_central_line);

%tempBW(handles.ordered_i(:), handles.ordered_j(:))=logical(0);
imshow(tempBW);

[y, x, button] = ginput(1);

    
while(button == 1)
    x=round(x); y=round(y);
    
    dist=getDistance(x,y,handles.ordered_i, handles.ordered_j, handles.distances);   
    
    set(handles.txtTemp, 'String', num2str(dist));
    [y, x, button] = ginput(1);
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[nrows, ncols] = size(handles.binary_image);

i=nrows - handles.ordered_i;
j=handles.ordered_j;


max_i = max(i);
mult_factor = 10^(ceil(log10(max_i)));

temp_j = j+(i/mult_factor);

sorted_temp_j = sort(temp_j);

sorted_j = (floor(sorted_temp_j));
sorted_i = ((sorted_temp_j - sorted_j)*mult_factor);

sorted_j = int16(sorted_j);
sorted_i = int16(sorted_i);

figure;
plot(sorted_j, sorted_i, '.'); xlim([0 ncols]); ylim([0 nrows]);






function txtTemp_Callback(hObject, eventdata, handles)
% hObject    handle to txtTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTemp as text
%        str2double(get(hObject,'String')) returns contents of txtTemp as a double


% --- Executes during object creation, after setting all properties.
function txtTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function txtAliasingAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to txtAliasingAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtAliasingAdjust as text
%        str2double(get(hObject,'String')) returns contents of txtAliasingAdjust as a double
handles.alias_adjust = str2num(get(handles.txtAliasingAdjust, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtAliasingAdjust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtAliasingAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


