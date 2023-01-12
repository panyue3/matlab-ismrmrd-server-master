function [respPT, respTime, param] = ProcessPT(PTData)

%% Define parameters
param.dsRate = 500;
param.numPT = 2000/param.dsRate; % number of PT per second
param.numVCha = 1;

%% Pre-processing PT data
valid = PTData(:,end)==5000;
timeAfterRF = PTData(:,end-1);
PTData(:,end-1:end) = [];
df = diff(timeAfterRF);
dt = max([mode(df(df~=0)), 500])*10^-6; % in sec
time = (0:dt:dt*(size(PTData,1)-1))';

fprintf('Total scan time: %.2f sec.\n',max(time))

if ~valid(end)
    time(find(diff(valid),1,'last')+1:end) = [];
    timeAfterRF(find(diff(valid),1,'last')+1:end) = [];
    PTData(find(diff(valid),1,'last')+1:end,:) = [];
    valid(find(diff(valid),1,'last')+1:end) = [];
end
if rem(length(PTData),2)
    PTData(end,:) = [];
    time(end) = [];
    timeAfterRF(end) = [];
    valid(end) = [];
end

validData = PTData;
validData(logical(~valid),:) = [];
validTime = time;
validTime(logical(~valid)) = [];
validData = interp1(validTime, validData,time,'pchip');
filtData = zeros(size(validData));
for i=1:size(validData,2)
    filtData(:,i) = lanczosfilter(validData(:,i), dt, 0.5*(1/dt/param.dsRate));
end
dsData = downsample(filtData(:,1:2:end) + filtData(:,2:2:end)*1i,param.dsRate);
respTime = downsample(time,param.dsRate);
param.timeAfterRF = timeAfterRF;

% ROVir
fROI = [0.1 0.8]; % MiniFlash - [0.1 1.8] Beat_PT - [0.1 3]
fInt = [0 0.05 1 Inf]; % MiniFlash - 1.95 Beat_PT - 4

% compute frequency
fs = 1/dt/param.dsRate;                  % Sampling frequency
L = length(dsData);  % Length of signal

X = fftshift(fft(dsData),1);
f = fs*((-L/2):(L/2)-1)/L;

% define ROI and interference
ROI = X;
ROI((f<-fROI(2) | (f>-fROI(1) & f<fROI(1)) | f>fROI(2)),:) = 0;

Int = X;
% Int((f>-fInt(3) & f<-fInt(2)) | (f>fInt(2) & f<fInt(3)),:) = 0;
Int(f>-fInt(3) & f<fInt(3),:) = 0;

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

end