function [net, param] = runTraining(imshift, ptdata, logging)

% Set network parameters
k = 0.8;
numRep = size(imshift,1);
endTrainFrame = round(numRep*k);
param = ptdata.param;
numHiddenUnits = 3;
numResponses = size(imshift,2);
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
    InTrain = [];
    nBeats = sum(ptdata.time(param.pk)<nSecs);
    InTrain{endTrainFrame-nBeats} = [];
    for ii = 1:(endTrainFrame-nBeats)
        InTrain{ii} = ptdata.data(param.pk(nBeats+ii)-param.numPT*nSecs+1:param.pk(nBeats+ii),:)';
    end

    if k~=1
        InCV = [];
        InCV{numRep-endTrainFrame} = [];
        for ii = 1:(numRep-endTrainFrame)
            InCV{ii} = ptdata.data(param.pk(endTrainFrame+ii)-param.numPT*nSecs+1:param.pk(endTrainFrame+ii),:)';
        end
    end

    OtTrain = tonndata(imshift(nBeats+1:endTrainFrame,:),false,false);
    if k~=1
        OtCV = tonndata(imshift(endTrainFrame+1:numRep,:),false,false);
    end

    options = trainingOptions('adam', ...
        'GradientThreshold',Inf, ...
        'GradientThresholdMethod','absolute-value', ...
        'MaxEpochs',6000, ...
        'MiniBatchSize',100, ...
        'InitialLearnRate',0.0025, ...
        'L2Regularization', 0.01, ...
        'ValidationData', {InCV', cell2mat(OtCV)'}, ...
        'Shuffle','every-epoch' , ...
        'Verbose',false);

    Net(nSecs) = trainNetwork(InTrain',cell2mat(OtTrain)',layers,options);

    % Training results
    yTrain = predict(Net(nSecs),InTrain,'MiniBatchSize',1)';
    TOTyTrain{nSecs} = yTrain;
    otTrain = cell2mat(OtTrain);
    TOTotTrain{nSecs} = otTrain;
    eTrain = otTrain - yTrain;
    TOTeTrain{nSecs} = eTrain;

    if k~=1
        yCV = predict(Net(nSecs),InCV,'MiniBatchSize',1)';
        TOTyCV{nSecs} = yCV;
        otCV = cell2mat(OtCV);
        TOTotCV{nSecs} = otCV;
        eCV = otCV - yCV;
        TOTeCV{nSecs} = eCV;
    end

    if k==1
        mean_err(nSecs) = sqrt(mean(eTrain(logical(sum(imshift)),:).^2,'all'));
        nmean_err(nSecs) = sqrt(sum(eTrain(logical(sum(imshift)),:).^2,'all') / sum(otTrain(logical(sum(imshift)),:).^2,'all'));
    else
        mean_err(nSecs) = sqrt(mean(eCV(logical(sum(imshift)),:).^2,'all'));
        nmean_err(nSecs) = sqrt(sum(eCV(logical(sum(imshift)),:).^2,'all') / sum(otCV(logical(sum(imshift)),:).^2,'all'));
    end

    logging.info('Finished trainning network, input %2i seconds, RMSE - %.2f.', nSecs, nmean_err(nSecs))
end

%%
[~, i] = min(nmean_err);
param.nSecs = i;
param.figName = fullfile(pwd,'output','Train_Result.png');

net = Net(i);
yTrain = TOTyTrain{i};
otTrain = TOTotTrain{i};
eTrain = TOTeTrain{i};
ylimit = [min([otTrain(:); yTrain(:); eTrain(:)]) max([otTrain(:); yTrain(:); eTrain(:)])];
fig = figure;
if k==1
    nStart = numRep-size(otTrain,2)+1;
    subplot(size(imshift,2),1,1); plot(nStart:numRep,otTrain(1,:),'k'); hold on; plot(nStart:numRep,yTrain(1,:),'k--'); plot(nStart:numRep,eTrain(1,:),'k:'); xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
    legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
    subplot(size(imshift,2),1,2); plot(nStart:numRep,otTrain(2,:),'k'); hold on; plot(nStart:numRep,yTrain(2,:),'k--'); plot(nStart:numRep,eTrain(2,:),'k:'); xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
    subplot(size(imshift,2),1,3); plot(nStart:numRep,otTrain(3,:),'k'); hold on; plot(nStart:numRep,yTrain(3,:),'k--'); plot(nStart:numRep,eTrain(3,:),'k:'); xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
    sgtitle(sprintf('num Secss: %i, Err: %.2f', i, nmean_err(i)))
    hold off
else
    yCV = TOTyCV{i};
    otCV = TOTotCV{i};
    eCV = TOTeCV{i};
    nStart = numRep-size([otTrain(1,:) otCV(1,:)],2)+1;
    subplot(size(imshift,2),1,1); plot(nStart:numRep,[otTrain(1,:) otCV(1,:)],'k'); hold on; plot(nStart:numRep,[yTrain(1,:) yCV(1,:)],'k--'); plot(nStart:numRep,[eTrain(1,:) eCV(1,:)],'k:'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
    legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
    subplot(size(imshift,2),1,2); plot(nStart:numRep,[otTrain(2,:) otCV(2,:)],'k'); hold on; plot(nStart:numRep,[yTrain(2,:) yCV(2,:)],'k--'); plot(nStart:numRep,[eTrain(2,:) eCV(2,:)],'k:'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
    subplot(size(imshift,2),1,3); plot(nStart:numRep,[otTrain(3,:) otCV(3,:)],'k'); hold on; plot(nStart:numRep,[yTrain(3,:) yCV(3,:)],'k--'); plot(nStart:numRep,[eTrain(3,:) eCV(3,:)],'k:'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
    sgtitle(sprintf('num Secs: %i, Err: %.2f', i, nmean_err(i)), 'FontSize', 20)
    hold off
    set(gcf,'Position', [0 0 1200 900])
end
saveas(fig, param.figName)
close(fig)

end