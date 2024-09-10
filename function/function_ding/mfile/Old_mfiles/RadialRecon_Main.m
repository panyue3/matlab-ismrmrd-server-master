clc
% clear all  
tic  
% filename = 'UID_1474624996_t1_radial3d_wfi.raw';
filename = '.\Raw\UID_1475839127_r2d_1slc_2_0_Itl_FA70.raw';

radialtype = 'radial_golden';       
% BW=400;
% Oversampling = 2;
% Dwell = 9.8; 

[rawdata0,phasecor,feed_back,noise_scan,rotAngleInPreScan,rotAngle] = Read_UIH_Raw_v5_2(filename);
% [rawdata0,phasecor,feed_back,noise_scan, SO0, SO1, SO2, SO3, pre_scan] = Read_UIH_Raw_v5_2(filename);
% rawdata0=squeeze(mean(rawdata0,3));
rawdata0 = single(rawdata0); 
% UTErawdata0 = single(UTErawdata0); 
size(rawdata0) 

[LPE LRO LCH]=size(rawdata0);
% if (LSL>1 || LEC>1)
    rotAngle=squeeze(rotAngle(1,1,:));
% else
%     rotAngle=squeeze(rotAngle);    
% end
phasecor=shiftdim(phasecor,2);
% toc  
% SO0(1:length(SO0)-size(rawdata0,1))=[];
% SO1(1:length(SO1)-size(rawdata0,1))=[];
% SO2(1:length(SO2)-size(rawdata0,1))=[];
% SO3(1:length(SO3)-size(rawdata0,1))=[];
XVec=zeros(1,length(rotAngle));
YVec=zeros(1,length(rotAngle));
ZVec=zeros(1,length(rotAngle));
% for i=1:length(SO0)
%         DHLangle=SO3(i)/180*pi;
%         m=SO2(i); n=-SO0(i);
%         u=cos(DHLangle)*SO2(i);
%         v=sin(DHLangle);
%         w=-cos(DHLangle)*SO0(i);
%         XVec(i)=u; YVec(i)=v; ZVec(i)=w;    
% end

for i=1:length(rotAngle)
        XVec(i)=cos(rotAngle(i)/180*pi); YVec(i)=sin(rotAngle(i)/180*pi); ZVec(i)=0;    
end

% GroupLength=size(rawdata0,1);  
% Group=0;  
% Offset=0; 
rawdata=squeeze(rawdata0(:,:,:));
[LPE  LRO LCH]=size(rawdata);
Vec = [XVec; YVec; ZVec];  
XShift = zeros(1,LCH);
YShift = zeros(1,LCH);
% ZShift = zeros(1,LCH);   
clear rawdata0;

%% hard code the first three points in UTE to be zero
% UTErawdata(:,1:3,:)=0;
%%

Target = [1 0. 0.];
Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);
[~ , XIndi] = min(fliplr(sum(Dist.^2)));
XIndi = length(Vec) + 1 - XIndi;    

Target=-Target;
% Target = -[Vec(1,XIndi) Vec(2,XIndi) Vec(3,XIndi)];
Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);
[~ , MXIndi] = min(fliplr(sum(Dist.^2)));
MXIndi = length(Vec) + 1 - MXIndi;   

Target = [0. 1 0.];    
Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);
[~ , YIndi] = min(fliplr(sum(Dist.^2)));
YIndi = length(Vec) + 1 - YIndi;    
Target=-Target;
% Target = -[Vec(1,YIndi) Vec(2,YIndi) Vec(3,YIndi)];
Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);
[~ , MYIndi] = min(fliplr(sum(Dist.^2)));
MYIndi = length(Vec) + 1 - MYIndi;     

% Target = [0. 0. 1];
% Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);
% [~ , ZIndi] = min(fliplr(sum(Dist.^2)));
% ZIndi = length(Vec) + 1 - ZIndi;    
% Target = -[Vec(1,ZIndi) Vec(2,ZIndi) Vec(3,ZIndi)];
% Dist = abs (Vec - [ones(size(XVec))*Target(1);ones(size(XVec))*Target(2);ones(size(XVec))*Target(3)]);         
% [~ , MZIndi] = min(fliplr(sum(Dist.^2)));
% MZIndi = length(Vec) + 1 - MZIndi;      

%%



