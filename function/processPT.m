function [respData, respTime, param] = processPT(Data, logging, param)

%% Define parameters
if nargin<3
    runTraining = true;
    param.dsRate = 50;
    param.numPT = 2000/param.dsRate; % number of PT per second
    param.numVCha = 4;
else
    runTraining = false;
end

%% Pre-processing PT data
respData = Data.rawdata;
valid = Data.isvalid;
time = Data.rawtime;
if nargin == 2
    logging.info("Total scan time: %.2f sec.",time(end))
end

% remove invalid samples and interpolate
if ~valid(end)
    time(find(diff(valid),1,'last')+1:end) = [];
    respData(find(diff(valid),1,'last')+1:end,:) = [];
    valid(find(diff(valid),1,'last')+1:end) = [];
end
if rem(length(respData),2)
    respData(end,:) = [];
    time(end) = [];
    valid(end) = [];
end

respData(~valid,:) = [];
validTime = time;
validTime(~valid) = [];

respData = interp1(validTime, respData,time,'pchip');

if runTraining
    % remove dc and drift
    [~, param.dedriftVec] = remove_drift(respData(Data.driftStart:end,:));
end
respData = respData*param.dedriftVec;
    
if runTraining
    % ROVir
    fROI = [0.1 0.8];
    fInt = [1 Inf];

    % compute frequency
    fs = 2000;                  % Sampling frequency
    L = length(respData);  % Length of signal
    X = fftshift(fft(respData),1);
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
end

respData = respData*param.V;
respData = medfilt1(cat(2,real(respData),imag(respData)), param.dsRate, [], 1);
respTime = downsample(time,param.dsRate);
if runTraining
    respData = downsample(respData,param.dsRate);
else
    respData = downsample(respData,param.dsRate) * diag(param.cor);
end

end