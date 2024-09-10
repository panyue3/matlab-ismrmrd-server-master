% This is to get the manual scar mass, the border and the border zone score
% from a bmp image.
% function [Total_M, Normal_M, Scar_M, Border, BZS] = Manual_Scar(fname);
% Total_M: Myocardium Mass; Normal_M: Normal Mass; Scar_M = Scar Mass; 
% Border: Scar border Mass; BZS: Border Zone Score (divided by Total_M)

function [Normal_M, Scar_M, Border_M, BZS_M] = Manual_Scar(fname);

if (findstr(fname,'.bmp')>1)
    x = 0; y = 0; x_0 = 0; y_0 = 0; s = 0;
    Raw_Image = imread(fname,'bmp');
    s = size(Raw_Image);

    % Initialize three matrices, they are all the same size as the original
    % images with values either zero or one.
    boundary_in = zeros(s(1),s(2));
    boundary_out = zeros(s(1),s(2));
    Infarct = zeros(s(1),s(2));

    % Find the boundaries and infarct region by analysis their color.
    boundary_in = (Raw_Image(:,:,1) == 205) & (Raw_Image(:,:,2) == 1) ; % Endocardium
    % The yelow letter make touch the boundar, make them boundary
    boundary_out = (Raw_Image(:,:,1) == 1) & (Raw_Image(:,:,2) == 205);% Epicardium
    boundary_out = bwmorph(boundary_out,'bridge' );
    boundary_out1 = (Raw_Image(:,:,1) == 255) & (Raw_Image(:,:,2) == 255);
    %boundary_out = bwmorph(boundary_out,'shrink');

    Infarct = (Raw_Image(:,:,1)-Raw_Image(:,:,2) == 51) ;
    Scar_M = sum(Infarct(:));

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
    Normal_M = sum(t_n(:));
    Total_M = sum(t_0(:));
 
%     % Find the mean grayscale of the normal myocardium.
%     mean_normal = sum(sum( double(gray_scale).*t_n ))/sum(t_n(:));
% 
%     % Find the mean grayscale of the normal myocardium.
%     mean_scar = sum(sum( double(gray_scale).*Infarct ))/sum(Infarct(:));
% 
%     % Find the normal myocardium STD
%     temp0 = double(gray_scale).*t_n;  % t_n is the normal myocardium. t_0 is the total myocardium
%     temp1 = temp0(find( temp0>0 )); % only the normal myocardium will be counted.
%     std_myocardium = std(temp1(:));

    % m_b is the normal myocardium neighbor to the scar
    m_b = 0;
    % Find who has scar neighbors
    m_b = sum(sum((bwmorph(Infarct,'dilate') - Infarct).*(t_0)));

    [x,y] = find(Infarct==1);
    n = length(x); neighbor = zeros(n,1); % Find how many pixels are there.
    % Do a FOR Loop to get the neighbor # of each pixel.
    for i=1:n
        %    b = Infarct((x(i)-1):(x(i)+1),(y(i)-1):(y(i)+1)); % 8-neighbor of the pixel of interest
        %    neighbor(i) = 9 - sum(b(:)); % Count the zeros in the 8-neighbor
        b = Infarct((x(i)-1):(x(i)+1),(y(i)-1):(y(i)+1))+ t_0((x(i)-1):(x(i)+1),(y(i)-1):(y(i)+1)); % Infarct=2, Normal =1;
        neighbor(i) = sum(sum(b==1)) ; % Number of normal myocardium Neighbors.
        a_n(i) = 9 - sum(sum(b==2))  ; % Number of any neighbors, including endocardium and epicardium.
    end
    
    Border_M = sum(m_b);
    BZS_M = sum(neighbor);
    
end















