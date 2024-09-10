close all;
clear all;


[fname,pname] = uigetfile('*.*','Select any one file from the Image series');

% in case user presses cancel
if (isequal(fname,0)|isequal(pname,0))
    return;
end;

raw_file_names=dir(fullfile(pname, '*.*'));

len=length(raw_file_names);

%this variable keeps count of blank file names
blank_count=0;
for i=1:len    
    if(strcmpi(raw_file_names(i).name,'.') | strcmpi(raw_file_names(i).name, '..'))
        blank_count = blank_count + 1;
    else
        file_names{i-blank_count, 1}=raw_file_names(i).name;
    end
end

mask_files=file_names(2*[1:length(file_names)./2]);
file_names(2*[1:length(file_names)./2]) = [];
image_files = file_names;
clear file_names;



for i=1:length(mask_files)
    
    Mask2D = double(rgb2gray(imread([pname mask_files{i}])));
    Image2D = double(rgb2gray(imread([pname image_files{i}])));  
    
    Mask2D = Mask2D/max(max(Mask2D));
    Image2D = Image2D/max(max(Image2D));
    
    BWInfarct = im2bw(Mask2D, max(max(Mask2D))- 0.1); % all pixels lower than the maximum will be darkened, leaving only the infarcted pixels bright
    InfarctImage = double(BWInfarct).*Image2D;
       
    [row_infarct, col_infarct]=find(BWInfarct); % gives the row and column numbers of white pixels. From the lenght of these vectors, we can find the number of white pixels
    no_of_infarct_pixels = length(row_infarct);
    avgInfarctIntensity = sum(sum(InfarctImage))/no_of_infarct_pixels; 
    
    
%     figure; imshow(Mask2D);
%     figure; imshow(Image2D);
    %%%%%%%%%%%%%block of code to find the normalized blood pool intensity
    
    % get the Binary image. Note that all the pixels above zero will be 1.
    % You will get the ring that is myocardium
    BW=im2bw(Mask2D,0);
    
    % get the center line of myocardium
    BW = bwmorph(BW,'shrink', Inf);
    
    % fill everything inside the center line
    [arranged_i,arranged_j]=arrange_points(BW);
    BW = roipoly(BW,arranged_i,arranged_j);
    
    % now you want to retain central 20% of this area. You may change this
    % value.
    BW1 = bwmorph(BW,'shrink', 1);
    while(logical(1))
        
        if(bwarea(BW1) < 0.2*bwarea(BW))
            break;
        end
        
        BW1 = bwmorph(BW1,'shrink', 1);
    end
    
    % mask BW1 with the Image
    I2 = double(BW1).*Image2D;
%     figure; imshow(I2);
    
    % use only the top 50% brightest blood pixels. You may change this.
    % value
    BW2 = im2bw(I2, 0.5*max(max(I2)));
%     figure; imshow(BW2);
    I3 = double(BW2).*I2;
%     figure; imshow(I3);
       
    [row_blood, col_blood]=find(BW2); % gives the row and column numbers of white pixels. From the lenght of these vectors, we can find the number of white pixels
    no_of_blood_pixels = length(row_blood);
    normalized_blood_pool = sum(sum(I3))/no_of_blood_pixels; % note that you can sum all the pixels in images. Non blood pool pixels are all black, zero, and hence dont contribute anything
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    arrayInfarctIntensity(i) = avgInfarctIntensity;
    arrayNormBlood(i) = normalized_blood_pool;

%     FinalResult{i+1,1} = image_files{i};
%     FinalResult{i+1,2} = avgInfarctIntensity;
%     FinalResult{i+1,3} = normalized_blood_pool;
    

end

NormArrayInfarctIntensity = arrayInfarctIntensity/mean(arrayNormBlood);

%TITLE ROW for final result
FinalResult{1,1} = 'File name';
FinalResult{1,2} = 'Infarct Intensity';
FinalResult{1,3} = 'Blood pool intensity';
FinalResult{1,4} = 'Infarct Normalized by average blood pool intensity';

N = length(NormArrayInfarctIntensity);
for i=2:N+1
    FinalResult{i,1} = image_files{i-1};
    FinalResult{i,2} = arrayInfarctIntensity(i-1);
    FinalResult{i,3} = arrayNormBlood(i-1);
    FinalResult{i,4} = NormArrayInfarctIntensity(i-1);
end

FinalResult{i+1,1} = 'Average';
FinalResult{i+1,2} = mean(arrayInfarctIntensity);
FinalResult{i+1,3} = mean(arrayNormBlood);
FinalResult{i+1,4} = mean(NormArrayInfarctIntensity);

xlswrite([pname 'Result.xls'], FinalResult);