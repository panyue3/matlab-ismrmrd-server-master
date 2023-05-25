function [respPT, respTime, param] = processPT(Data, logging, param)

%% Define parameters
if nargin<3
    runTraining = true;
    param.dsRate = 100;
    param.numPT = 2000/param.dsRate; % number of PT per second
    param.numVCha = 4;
else
    runTraining = false;
end
ncha = size(Data.rawdata,2);
dt = 500*10^-6; % in sec

%% Pre-processing PT data
ptData = Data.rawdata;
ptData(end,:) = [];
valid = Data.isvalid;
valid(end) = [];
time =Data.rawtime;
time(end) = [];

if ~valid(end)
    time(find(diff(valid),1,'last')+1:end) = [];
    ptData(find(diff(valid),1,'last')+1:end,:) = [];
    valid(find(diff(valid),1,'last')+1:end) = [];
end
if rem(length(ptData),2)
    ptData(end,:) = [];
    time(end) = [];
    valid(end) = [];
end

ptData(~valid,:) = [];
validTime = time;
validTime(~valid) = [];

if nargin == 2
    logging.info("Total scan time: %.2f sec.",max(time))
end

interpData = interp1(validTime, ptData,time,'pchip');
filtData = cat(2,real(interpData),imag(interpData));
parfor i=1:ncha*2
    filtData(:,i) = lanczosfilter(filtData(:,i), dt, 0.5*(1/dt/param.dsRate));
end
dsData = downsample(filtData(:,1:ncha) + filtData(:,ncha+1:end)*1i,param.dsRate);
respTime = downsample(time,param.dsRate);

if runTraining
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
    respPT = cat(2,real(rovirData),imag(rovirData));
    respPT(1,:) = [];
    respTime(1,:) = [];

    param.M = mean(respPT);
    param.SD = std(respPT);
else
    rovirData = dsData*param.V;
    respPT = cat(2,real(rovirData),imag(rovirData)) * diag(param.cor);
    respPT(1,:) = [];
    respTime(1,:) = [];
end

respPT = (respPT - param.M) ./ param.SD;

end