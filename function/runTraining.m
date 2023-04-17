function [net, param] = runTraining(imdata, ptdata, logging)

% Set network parameters
param = ptdata.param;
ptdata.data = (ptdata.data - param.M) ./ param.SD;
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

    options = trainingOptions('rmsprop', ...
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
    eData = OtData - yData;
    TOTyData{nSecs} = yData;
    TOTotData{nSecs} = OtData;
    TOTeData{nSecs} = eData;
    yTrain = predict(Net{nSecs},InTrain,'MiniBatchSize',1);
    eTrain = OtTrain - yTrain;
    yCV = predict(Net{nSecs},InCV,'MiniBatchSize',1);
    eCV = OtCV - yCV;
    TOTyCV{nSecs} = yCV;
    TOTotCV{nSecs} = OtCV;
    TOTeCV{nSecs} = eCV;
    TOTidxCV{nSecs} = idxCV;

    nmse_train(nSecs) = sqrt(sum(eTrain.^2,'all') / sum(OtTrain.^2,'all'));
    nmse_cv(nSecs) = sqrt(sum(eCV.^2,'all') / sum(OtCV.^2,'all'));

    logging.info('Finished trainning network, input %2i seconds, Train Err: %.2f, CV Err: %.2f.', nSecs, nmse_train(nSecs), nmse_cv(nSecs))
end

%%
[~, i] = min(nmse_cv);
param.nSecs = i;
nBeats = sum(ptdata.time(param.pk)<i);
isoutlier = logical(conv(imdata.isoutlier,[zeros(nBeats,1); ones(nBeats,1)],'same'));

net = Net{i};
yData = TOTyData{i};
OtData = TOTotData{i};
eData = TOTeData{i};
yCV = TOTyCV{i};
OtCV = TOTotCV{i};
eCV = TOTeCV{i};
idxCV = TOTidxCV{i};
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
sgtitle(sprintf('num Secss: %i, Train Err: %.2f, CV Err: %.2f', i, nmse_train(i), nmse_cv(i)))
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