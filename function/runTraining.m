function [net, param] = runTraining(imdata, ptdata, logging)

% Set network parameters
param = ptdata.param;
param.maxThred = imdata.maxThred;
param.minThred = imdata.minThred;
numRep = size(imdata.shiftvec,1);
numHiddenUnits = 11;
numResponses = size(imdata.shiftvec,2);
netstruct = 'LSTM';

switch netstruct
    case 'LSTM'
        layers = [...
            sequenceInputLayer(param.numVCha* 2)
            lstmLayer(numHiddenUnits,'OutputMode','last')
            fullyConnectedLayer(numResponses)
            regressionLayer];
    case 'BiLSTM'
        layers = [...
            sequenceInputLayer(param.numVCha*2)
            bilstmLayer(numHiddenUnits,'OutputMode','last')
            fullyConnectedLayer(numResponses)
            regressionLayer];
end

%%
parfor nSecs=1:10
    % Pack PT and Disp data into NN input and output arrays
    InData = [];
    nBeats = sum(ptdata.time(param.pk)<nSecs);
    InData{numRep-nBeats} = [];
    for ii = 1:(numRep-nBeats)
        InData{ii} = ptdata.data(param.pk(nBeats+ii)-param.numPT*nSecs+1:param.pk(nBeats+ii),:)';
        InData{ii} = (InData{ii} - mean(InData{ii},2)) ./ std(InData{ii},[],2);
    end
    OtData = imdata.shiftvec(nBeats+1:numRep,:);

    [idxTrain,idxCV] = trainingPartitions(numRep-nBeats, [0.8 0.2]);
    
    InTrain = InData(idxTrain);
    InCV = InData(idxCV);
    OtTrain = OtData(idxTrain,:);
    OtCV = OtData(idxCV,:);

    options = trainingOptions('rmsprop', ...
        'ExecutionEnvironment','cpu', ...
        'GradientThreshold',0.25, ...
        'GradientThresholdMethod','l2norm', ...
        'MaxEpochs',3500, ...
        'MiniBatchSize',1024, ...
        'InitialLearnRate',0.075, ...
        'L2Regularization',0.025, ...
        'ValidationData', {InCV', OtCV}, ...
        'OutputNetwork', 'best-validation-loss', ...
        'ValidationPatience',200,...
        'Shuffle','never' , ...
        'Verbose',false);

    net = trainNetwork(InTrain',OtTrain,layers,options);
    Net{nSecs} = net;

    % Training results
    yData = predict(Net{nSecs},InData,'MiniBatchSize',1);
    TOTyData{nSecs} = yData;
    eTrain = OtTrain - yData(idxTrain,:);
    eCV = OtCV - yData(idxCV,:);
    TOTidxCV{nSecs} = idxCV;
    TOTidxTrain{nSecs} = idxTrain;

%     err_train(nSecs) = sqrt(sum(eTrain.^2,'all') / sum(OtTrain.^2,'all'));
%     err_cv(nSecs) = sqrt(sum(eCV.^2,'all') / sum(OtCV.^2,'all'));
    err_train = 10 * log10(sum(eTrain.^2,'all') / sum(OtTrain.^2,'all'));
    err_cv(nSecs) = 10 * log10(sum(eCV.^2,'all') / sum(OtCV.^2,'all'));

    logging.info('Network %2i, Train Err: %.2f, CV Err: %.2f.', nSecs, err_train, err_cv(nSecs))

    % Reset gpu device
    if gpuDeviceCount
        gpuDevice([]);
    end
end

%%
[~, i] = min(err_cv);
param.nSecs = i;
nBeats = sum(ptdata.time(param.pk)<i);

net = Net{i};
yData = cat(1, nan(nBeats,3),TOTyData{i});
OtData = imdata.shiftvec;
OtData(1:nBeats,:) = nan;
idx.CV = TOTidxCV{i} + nBeats;
idx.Train = TOTidxTrain{i} + nBeats;
param.figName = genPlots(OtData, yData, param, idx);

end