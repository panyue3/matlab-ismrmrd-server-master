% This is to find the total myocardium, the scar, and the normal myocardium.
% function [normal,scar] = QMass_Results(fname); 
% output normal and scar are the pixel values (size: number of pixels, value: gray scale)

function [normal,scar] = QMass_Results(fname);

Raw_Image = imread(fname,'bmp');
s = size(Raw_Image);

% Initialize three matrices, they are all the same size as the original
% images with values either zero or one.
boundary_in = zeros(s(1),s(2));
boundary_out = zeros(s(1),s(2));
Infarct = zeros(s(1),s(2));

% Find the boundaries and infarct region by analysis their color.
boundary_in = (Raw_Image(:,:,1) == 205) & (Raw_Image(:,:,2) == 1) ; % Endocardium
boundary_out = (Raw_Image(:,:,1) == 1) & (Raw_Image(:,:,2) == 205) ;% Epicardium
Infarct = (Raw_Image(:,:,1)-Raw_Image(:,:,2) == 51) ;

if max(max(double(Raw_Image(:,:,1)).*Infarct))>204,
    gray_scale = Raw_Image(:,:,1);
else
    gray_scale = Raw_Image(:,:,3);
end

%imagesc(Infarct)
%imagesc(boundary_in + boundary_out);
[y,x] = find(boundary_in==1);
x0 = round(mean(x)); % Find the center of the boundary x0, y0
y0 = round(mean(y));
t_1 = bwfill(boundary_in+boundary_out,x0,y0,8); % Fillthe hole from a seed at the center x0,y0. use 8 neighbour fill

%x = 0; y = 0;
[y,x] = find(boundary_out==1);
x0 = round(mean(x)); % Find the center of the boundary x0, y0
y0 = round(mean(y));
t_2 = bwfill(boundary_out,x0,y0,8); % Fillthe hole from a seed at the center x0,y0. use 8 neighbour fill
t_0 = t_2 - t_1; % All the myocardium within inner and outer boundary.

% Find the normal myocardium t_n.
t_n = t_0 - Infarct;
[x_n, y_n] = find((t_n)==1);

% Find the mean grayscale of the normal myocardium.
mean_normal = sum(sum( double(gray_scale).*t_n ))/sum(t_n(:));

% Find the mean grayscale of the normal myocardium.
mean_scar = sum(sum( double(gray_scale).*Infarct ))/sum(Infarct(:));

% Find the normal myocardium STD
temp0 = double(gray_scale).*t_n;  % t_n is the normal myocardium. t_0 is the total myocardium
temp1 = temp0(find( temp0>0 )); % only the normal myocardium will be counted.
std_myocardium = std(temp1(:));

% m_b is the normal myocardium neighbor to the scar
m_b = 0;
% Find who has scar neighbors
m_b = sum(sum((bwmorph(Infarct,'dilate') - Infarct).*(t_0)));

















