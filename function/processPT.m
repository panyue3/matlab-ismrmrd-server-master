function [respPT, respTime, param] = processPT(PTData, logging)

%% Define parameters
param.dsRate = 400;
param.numPT = 2000/param.dsRate; % number of PT per second
param.numVCha = 1;

%% Pre-processing PT data
PTData(end,:) = [];
validTime = (PTData(:,end)-PTData(1,end))*10^-6; % in sec
timeAfterRF = PTData(:,end-1);
PTData(:,end-1:end) = [];
df = diff(timeAfterRF);
dt = 500*10^-6; % in sec
time = (0:dt:max(validTime))';

if rem(length(time),2)
    time(end) = [];
end

logging.info("Total scan time: %.2f sec.",max(validTime))

validData = interp1(validTime, PTData,time,'pchip');
filtData = zeros(size(validData));
for i=1:size(validData,2)
    filtData(:,i) = lanczosfilter(validData(:,i), dt, 0.5*(1/dt/param.dsRate));
end
dsData = downsample(filtData(:,1:2:end) + filtData(:,2:2:end)*1i,param.dsRate);
respTime = downsample(time,param.dsRate);

% ROVir
fROI = [0.1 0.8];
fInt = [1 Inf];

% compute frequency
fs = 1/dt/param.dsRate;                  % Sampling frequency
L = length(dsData);  % Length of signal

X = fftshift(fft(dsData),1);
f = fs*((-L/2):(L/2)-1)/L;

% define ROI and interference
ROI = X;
ROI((f<-fROI(2) | (f>-fROI(1) & f<fROI(1)) | f>fROI(2)),:) = 0;

Int = X;
Int(f>-fInt(1) & f<fInt(1),:) = 0;

cROI = cov(ROI);
cInt = cov(Int);

[V, D] = eig(cROI, cInt);
[~, vIdx] = sort(diag(D),'descend');
param.V = V(:,vIdx(1:param.numVCha));

rovirData = dsData*param.V;
rovirData = cat(2,real(rovirData),imag(rovirData));

param.M = mean(rovirData);
param.SD = std(rovirData);

respPT = (rovirData - param.M) ./ param.SD;
respPT(1,:) = [];
respTime(1,:) = [];

% find cardiac trigger
[~, pk] = findpeaks(timeAfterRF,"MinPeakHeight", 0.05*max(timeAfterRF));
param.pk = [1; round(pk/param.dsRate)];

end