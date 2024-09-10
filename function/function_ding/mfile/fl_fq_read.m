 clear all; 
 close all;
%  [RawData,NumberOfChannels,OffCen,CenPE] = reading_raw('C:\Program Files\MATLAB71\work\Research\Flow rawdata\meas_flow.out',1,15);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reconstruction rectlinear trajectory raw data from scanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain raw data sets

% ImgName = input('Enter the name of the output file:','s');
% RowNum  = input('Enter the number of rows:');
% ColNum  = input('Enter the number of columns:');
% AveNum  = input('Enter the number of repetitions:');
% ChaNum  = input('Enter the number of channels:');
% PhaseNum = input('Enter the number of phases:');

ImgName = 'C:\Program Files\MATLAB71\work\Research\Flow_rawdata\leg_flow1';
RowNum  = 256; ColNum  = 256; AveNum  = 1; ChaNum  = 2; PhaseNum = 41;

%ImgName = 'C:\Program Files\MATLAB71\work\Research\Flow_rawdata\measphase8';
%RowNum  = 128; ColNum  = 128; AveNum  = 1; ChaNum  = 1; PhaseNum = 8;

TotalImage = zeros(RowNum, ColNum, AveNum, PhaseNum);
TotalColNum = ColNum * 2 ;        
TotalRowNum = RowNum * AveNum * ChaNum * PhaseNum * 2;      % flow compensate and flow encoding
c1 = clock, raw2matmr1(ImgName,'lin', TotalRowNum, TotalColNum ); load lin; c2 = clock, c2-c1

a = rawdata;

figure;
subplot(321); imagesc(flipud(abs(fftshift(ifft2(fftshift(a(1:2*PhaseNum:end, :))))))), axis image, colormap gray;
subplot(322); imagesc(flipud(angle(fftshift(ifft2(fftshift(a(1:2*PhaseNum:end, :))))))),, axis image, colormap gray;
subplot(323); imagesc(flipud(abs(fftshift(ifft2(fftshift(a(2:2*PhaseNum:end, :))))))), axis image, colormap gray;
subplot(324); imagesc(flipud(angle(fftshift(ifft2(fftshift(a(2:2*PhaseNum:end, :))))))), axis image, colormap gray;
subplot(325); imagesc(flipud(fftshift(abs(ifft2(fftshift(a(1:2*PhaseNum:end, :))))-abs(ifft2(fftshift(a(2:2*PhaseNum:end, :))))))), axis image, colormap gray;
subplot(326); imagesc(flipud(fftshift(angle(ifft2(fftshift(a(1:2*PhaseNum:end, :))))-angle(ifft2(fftshift(a(2:2*PhaseNum:end, :))))))), axis image, colormap gray;

figure;
for i = 1:PhaseNum*2-1
    subplot(231); imagesc(flipud(abs(fftshift(ifft2(fftshift(a(i:2*PhaseNum:end, 1:2:end))))))), axis image, colormap gray, title ('Mag. Image w/ full data');
    subplot(232); imagesc(flipud(fftshift(angle(ifft2(fftshift(a(i:2*PhaseNum:end, 1:2:end)))) ...
                                        - angle(ifft2(fftshift(a(i+1:2*PhaseNum:end, 1:2:end))))))), axis image, colormap gray, title ('Case (I):Phase Image, w/ full data');
                              
    temp_fc = zeros(RowNum, ColNum);  
    temp_fe = zeros(RowNum, ColNum);
    temp_fc(:,:) = a(i:2*PhaseNum:end, 1:2:end);
    temp_fe(:,:) = a(i+1:2*PhaseNum:end, 1:2:end);
    temp_fe(1:31, :)= 0;
    temp_fe(97:end, :) = 0;
    subplot(233); imagesc(flipud(fftshift(angle(ifft2(fftshift(temp_fc(:,:)))) ...
                                        - angle(ifft2(fftshift(temp_fe(:,:))))))), axis image, colormap gray, title ('Case (II): Phase Image, 50% data w/ zero pad');
                                    
    temp_fe(:,:) = a(i+1:2*PhaseNum:end, 1:2:end);
    first_fe = zeros(RowNum, ColNum);
    first_fe(:,:) = a(2:2*PhaseNum:end, 1:2:end);
    temp_fe(1:31, :)= first_fe(1:31, :);
    temp_fe(97:end, :) = first_fe(97:end, :);                                    
    subplot(234); imagesc(flipud(fftshift(angle(ifft2(fftshift(temp_fc(:,:)))) ...
                                        - angle(ifft2(fftshift(temp_fe(:,:))))))), axis image, colormap gray, title ('Case (III): Phase Image, 50% data w/ filled first full image data');
    
    temp_fe(:,:) = a(i+1:2*PhaseNum:end, 1:2:end);
    partial_fe = zeros(RowNum, ColNum);
    partial_fe(:,:) = a(2:2*PhaseNum:end, 1:2:end);
    temp_fe(81:end, :) = conj(first_fe(48:-1:1, :));                                    
    subplot(235); imagesc(flipud(fftshift(angle(ifft2(fftshift(temp_fc(:,:)))) ...
                                        - angle(ifft2(fftshift(temp_fe(:,:))))))), axis image, colormap gray, title ('Case (IV): Phase Image, 65% data and complex conjuction');
                                   
    pause(1)

end

