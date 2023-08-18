function [respPT, respTime, param] = processPT(Data, logging, param)

%% Define parameters
if nargin<3
    runTraining = true;
    param.dsRate = 400;
    param.numPT = 2000/param.dsRate; % number of PT per second
    param.numVCha = 4;
else
    runTraining = false;
end
dt = 500*10^-6; % in sec

%% Pre-processing PT data
ptData = Data.rawdata;
valid = Data.isvalid;
time =Data.rawtime;
if runTraining
    ptData(end,:) = [];
    valid(end) = [];
    time(end) = [];
end

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
if ~runTraining
    ptData = ptData - param.testM + param.trainM;
end
validTime = time;
validTime(~valid) = [];

if nargin == 2
    logging.info("Total scan time: %.2f sec.",max(time))
end

interpData = interp1(validTime, ptData,time,'pchip');
respTime = downsample(time,param.dsRate);

if runTraining
    % ROVir
    fROI = [0.1 0.8];
    fInt = [1 Inf];
    
    % compute frequency
    fs = 1/dt;                  % Sampling frequency
    L = length(interpData);  % Length of signal
    
    X = fftshift(fft(interpData),1);
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
    rovirData = interpData*param.V;

    filtData = cat(2,real(rovirData),imag(rovirData));
    parfor i=1:param.numVCha*2
        filtData(:,i) = lanczosfilter(filtData(:,i), dt, 0.5*(1/dt/param.dsRate));
    end
    respPT = downsample(filtData,param.dsRate);
    respPT(1,:) = [];
    respTime(1,:) = [];

    param.trainM = mean(ptData);
else
    rovirData = interpData*param.V;
    filtData = cat(2,real(rovirData),imag(rovirData));
    parfor i=1:param.numVCha*2
        filtData(:,i) = lanczosfilter(filtData(:,i), dt, 0.5*(1/dt/param.dsRate));
    end
    respPT = downsample(filtData,param.dsRate) * diag(param.cor);
end

end