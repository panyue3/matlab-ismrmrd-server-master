function [net, param] = runTraining(imdata, ptdata, logging)

% Set network parameters
param = ptdata.param;
numRep = size(imdata.shiftvec,1);
numHiddenUnits = 11;
numEpoch = 3500;
initLearnRate = 0.075;
l2Reg = 0.025;
netStruct = 'LSTM';
solName = 'rmsprop';
gradthreMod = 'l2norm';

%%
vars = optimizableVariable('nSec', [1, 10], 'Type', 'integer');
minfn = @(T)kfoldLoss(ptdata, imdata, T.nSec, numEpoch, numHiddenUnits, initLearnRate, l2Reg, netStruct, solName, gradthreMod);
results = bayesopt(minfn, vars,'UseParallel', true);
T = bestPoint(results);
nSecs = T.nSec;

% Pack PT and Disp data into NN input and output arrays
layers = packLayers(netStruct, param.numVCha, numHiddenUnits, size(imdata.shiftvec,2));

InData = [];
nBeats = sum(ptdata.time(param.pk)<nSecs);
InData{numRep-nBeats} = [];
for ii = 1:(numRep-nBeats)
    InData{ii} = ptdata.data(param.pk(nBeats+ii)-param.numPT*nSecs+1:param.pk(nBeats+ii),:)';
end
OtData = imdata.shiftvec(nBeats+1:numRep,:);

[idxTrain,idxCV] = trainingPartitions(numRep-nBeats, [0.8 0.2]);

% Exclude outliers
isoutlier = logical(conv(imdata.isoutlier,[zeros(nBeats,1); ones(nBeats,1)],'same'));
idxTrain = setdiff(idxTrain, find(isoutlier)-nBeats);
idxCV = setdiff(idxCV, find(isoutlier)-nBeats);

InTrain = InData(idxTrain);
InCV = InData(idxCV);
OtTrain = OtData(idxTrain,:);
OtCV = OtData(idxCV,:);

options = trainingOptions(solName, ...
    'GradientThreshold',0.25, ...
    'GradientThresholdMethod',gradthreMod, ...
    'MaxEpochs',numEpoch, ...
    'MiniBatchSize',1024, ...
    'InitialLearnRate',initLearnRate, ...
    'L2Regularization',l2Reg, ...
    'ValidationData', {InCV', OtCV}, ...
    'OutputNetwork', 'best-validation-loss', ...
    'ValidationPatience',200,...
    'Shuffle','never' , ...
    'Verbose',false);

net = trainNetwork(InTrain',OtTrain,layers,options);

% Training results
yData = predict(net,InData,'MiniBatchSize',1);
eData = OtData - yData;
yCV = predict(net,InCV,'MiniBatchSize',1);
eCV = OtCV - yCV;

nmse_train = sqrt(sum(eTrain.^2,'all') / sum(OtTrain.^2,'all'));
nmse_cv = sqrt(sum(eCV.^2,'all') / sum(OtCV.^2,'all'));

logging.info('Finished trainning network, input %2i seconds, Train Err: %.2f, CV Err: %.2f.', nSecs, nmse_train, nmse_cv)

%%
ylimit = [min([OtData(:); yData(:); eData(:)]) max([OtData(:); yData(:); eData(:)])];
fig = figure;
subplot(size(imdata.shiftvec,2),1,1); plot(nBeats+1:numRep,OtData(:,1),'k'); hold on; plot(nBeats+1:numRep,yData(:,1),'k--'); plot(nBeats+1:numRep,eData(:,1),'k:'); 
xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit); plot(nBeats+idxCV,eCV(:,1),'bx','MarkerSize',10);
if(find(imdata.isoutlier,1)); xline(find(imdata.isoutlier),'LineWidth',2,'Color',[0.7 0.7 0.7]);end
legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
subplot(size(imdata.shiftvec,2),1,2); plot(nBeats+1:numRep,OtData(:,2),'k'); hold on; plot(nBeats+1:numRep,yData(:,2),'k--'); plot(nBeats+1:numRep,eData(:,2),'k:'); 
xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit); plot(nBeats+idxCV,eCV(:,2),'bx','MarkerSize',10);
if(find(imdata.isoutlier,1)); xline(find(imdata.isoutlier),'LineWidth',2,'Color',[0.7 0.7 0.7]);end
subplot(size(imdata.shiftvec,2),1,3); plot(nBeats+1:numRep,OtData(:,3),'k'); hold on; plot(nBeats+1:numRep,yData(:,3),'k--'); plot(nBeats+1:numRep,eData(:,3),'k:'); 
xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit); plot(nBeats+idxCV,eCV(:,3),'bx','MarkerSize',10);
if(find(imdata.isoutlier,1)); xline(find(imdata.isoutlier),'LineWidth',2,'Color',[0.7 0.7 0.7]);end
sgtitle(sprintf('num Secss: %i, Train Err: %.2f, CV Err: %.2f', nSecs, nmse_train, nmse_cv))
hold off
set(gcf,'Position', [0 0 1200 900])
param.figName{1} = fullfile(pwd,'output','Train_Result.png');
saveas(fig, param.figName{1})
close(fig)  

yData(isoutlier(nBeats+1:numRep),:) = nan;
OtData(isoutlier(nBeats+1:numRep),:) = nan;
fig = figure;
hold on
scatter(yData(:,1),OtData(:,1),'k.');
scatter(yData(:,2),OtData(:,2),'k.');
scatter(yData(:,3),OtData(:,3),'k.');
scatter(yCV(:,1),OtCV(:,1),'k+');
scatter(yCV(:,2),OtCV(:,2),'kx');
scatter(yCV(:,3),OtCV(:,3),'ko');
xlabel("Predicted Shift")
ylabel("Actual Shift")
m = min(OtData,[],'all');
M=max(OtData,[],'all');
xlim([m M])
ylim([m M])
plot([m M], [m M], "r--")
legend('Train','','','dX','dY','dZ','','Location','Best')
param.figName{2} = fullfile(pwd,'output','Predit.vs.Actual.png');
saveas(fig, param.figName{2})
close(fig)

end

function rmse = kfoldLoss(ptdata, imdata, nSec, nEpoch, nHiddenUnits, initLearnRate, l2Reg, netStruct, solName, gradthreMod)
param = ptdata.param;
numRep = numel(imdata.isoutlier);
shiftvec = imdata.shiftvec;
isoutlier = imdata.isoutlier;
data = ptdata.data;

layers = packLayers(netStruct, param.numVCha, nHiddenUnits, size(imdata.shiftvec,2));

% Pack PT and Disp data into NN input and output arrays
InData = [];
nBeats = sum(ptdata.time(param.pk)<nSec);
InData{numRep-nBeats} = [];
for ii = 1:(numRep-nBeats)
    InData{ii} = data(param.pk(nBeats+ii)-param.numPT*nSec+1:param.pk(nBeats+ii),:)';
end
OtData = shiftvec(nBeats+1:numRep,:);

isoutlier = logical(conv(isoutlier,[zeros(nBeats,1); ones(nBeats,1)],'same'));
c = cvpartition(numRep-nBeats,'KFold',5);
nmse_fold = nan(1,5);
for ifold = 1:5
    idxTrain = find(training(c,ifold));
    idxCV = find(test(c,ifold));

    % Exclude outliers
    idxTrain = setdiff(idxTrain, find(isoutlier)-nBeats);
    idxCV = setdiff(idxCV, find(isoutlier)-nBeats);

    InTrain = InData(idxTrain);
    InCV = InData(idxCV);
    OtTrain = OtData(idxTrain,:);
    OtCV = OtData(idxCV,:);

    options = trainingOptions(solName, ...
        'Verbose',false, ...
        'ValidationData', {InCV', OtCV}, ...
        'ValidationPatience',200, ...
        'OutputNetwork', 'best-validation-loss', ...
        'Shuffle','never' , ...
        'MaxEpochs',nEpoch, ...
        'MiniBatchSize',1024, ...
        'GradientThreshold',0.25, ...
        'GradientThresholdMethod',gradthreMod, ...
        'InitialLearnRate',initLearnRate, ...
        'L2Regularization',l2Reg);

    net = trainNetwork(InTrain',OtTrain,layers,options);

    % Training results
    yCV = predict(net,InCV,'MiniBatchSize',1);
    eCV = OtCV - yCV;

    nmse_fold(ifold) = sqrt(sum(eCV.^2,'all') / sum(OtCV.^2,'all'));
end

rmse = mean(nmse_fold);
end

function layers = packLayers(netStruct, nVCha, nHiddenUnits, numResponses)
switch netStruct
    case 'LSTM'
        layers = [...
            sequenceInputLayer(nVCha* 2)
            lstmLayer(nHiddenUnits,'OutputMode','last')
            fullyConnectedLayer(numResponses)
            regressionLayer];
    case 'BiLSTM'
        layers = [...
            sequenceInputLayer(nVCha*2)
            bilstmLayer(nHiddenUnits,'OutputMode','last')
            fullyConnectedLayer(numResponses)
            regressionLayer];
end
end