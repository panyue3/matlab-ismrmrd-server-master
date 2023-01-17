function runPredict(imshift, ptdata, logging)

% Set network parameters
param = ptdata.param;
numHiddenUnits1 = 5;
numHiddenUnits2 = 3;
numResponses = size(imshift,2);
netstruct = 'LSTM';

switch netstruct
    case 'LSTM'
        layers = [...
            sequenceInputLayer(param.numVCha* 2)
            lstmLayer(numHiddenUnits1,'OutputMode','last')
            fullyConnectedLayer(numHiddenUnits2)
            fullyConnectedLayer(numResponses)
            regressionLayer];
    case 'BiLSTM'
        layers = [...
            sequenceInputLayer(param.numVCha*2)
            bilstmLayer(numHiddenUnits1,'OutputMode','last')
            fullyConnectedLayer(numHiddenUnits2)
            fullyConnectedLayer(numResponses)
            regressionLayer];
end

%%
for nSecs=1:10
    % Pack PT and Disp data into NN input and output arrays
    InTrain = [];
    nBeats = sum(respTime(pk)<nSecs);
    InTrain{endTrainFrame-nBeats} = [];
    for ii = 1:(endTrainFrame-nBeats)
        InTrain{ii} = respPT(pk(nBeats+ii)-param.numPT*nSecs+1:pk(nBeats+ii),:)';
    end

    if k~=1
        InCV = [];
        InCV{nRep-endTrainFrame} = [];
        for ii = 1:(nRep-endTrainFrame)
            InCV{ii} = respPT(pk(endTrainFrame+ii)-param.numPT*nSecs+1:pk(endTrainFrame+ii),:)';
        end
    end

    OtTrain = tonndata(ImData(nBeats+1:endTrainFrame,:),false,false);
    if k~=1
        OtCV = tonndata(ImData(endTrainFrame+1:nRep,:),false,false);
    end

    options = trainingOptions('adam', ...
        'GradientThreshold',Inf, ...
        'GradientThresholdMethod','absolute-value', ...
        'MaxEpochs',200, ...
        'MiniBatchSize',20, ...
        'InitialLearnRate',0.0025, ...
        'ValidationData', {InCV', cell2mat(OtCV)'}, ...
        'Shuffle','every-epoch' , ...
        'Plots','training-progress');

    Net(nSecs) = trainNetwork(InTrain',cell2mat(OtTrain)',layers,options);

    % Plot training results
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

%     nStart = nBeats+1;
%     ylimit = [min([otTrain(:); yTrain(:); eTrain(:)]) max([otTrain(:); yTrain(:); eTrain(:)])];
    if k==1
        mean_err(nSecs) = sqrt(mean(eTrain(logical(sum(ImData)),:).^2,'all'));
        nmean_err(nSecs) = sqrt(sum(eTrain(logical(sum(ImData)),:).^2,'all') / sum(otTrain(logical(sum(ImData)),:).^2,'all'));
        
%         figure
%         subplot(size(ImData,2),1,1);
%         plot(nStart:nRep,otTrain(1,:)); hold on; plot(nStart:nRep,yTrain(1,:),'g'); plot(nStart:nRep,eTrain(1,:),'r'); xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
%         legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
%         subplot(size(ImData,2),1,2); plot(nStart:nRep,otTrain(2,:)); hold on; plot(nStart:nRep,yTrain(2,:),'g'); plot(nStart:nRep,eTrain(2,:),'r'); xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
%         subplot(size(ImData,2),1,3); plot(nStart:nRep,otTrain(3,:)); hold on; plot(nStart:nRep,yTrain(3,:),'g'); plot(nStart:nRep,eTrain(3,:),'r'); xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
%         sgtitle(sprintf('num Secs: %i, Err: %.2f', nSecs, nmean_err(nSecs)))
%         hold off
    else
        mean_err(nSecs) = sqrt(mean(eCV(logical(sum(ImData)),:).^2,'all'));
        nmean_err(nSecs) = sqrt(sum(eCV(logical(sum(ImData)),:).^2,'all') / sum(otCV(logical(sum(ImData)),:).^2,'all'));
        
%         figure
%         subplot(size(ImData,2),1,1);
%         plot(nStart:nRep,[otTrain(1,:) otCV(1,:)]); hold on; plot(nStart:nRep,[yTrain(1,:) yCV(1,:)],'g'); plot(nStart:nRep,[eTrain(1,:) eCV(1,:)],'r');
%         xline(size(otTrain,2)+nBeats,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
%         legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
%         subplot(size(ImData,2),1,2); plot(nStart:nRep,[otTrain(2,:) otCV(2,:)]); hold on; plot(nStart:nRep,[yTrain(2,:) yCV(2,:)],'g'); plot(nStart:nRep,[eTrain(2,:) eCV(2,:)],'r');
%         xline(size(otTrain,2)+nBeats,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
%         subplot(size(ImData,2),1,3); plot(nStart:nRep,[otTrain(3,:) otCV(3,:)]); hold on; plot(nStart:nRep,[yTrain(3,:) yCV(3,:)],'g'); plot(nStart:nRep,[eTrain(3,:) eCV(3,:)],'r');
%         xline(size(otTrain,2)+nBeats,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
%         sgtitle(sprintf('num Secs: %i, Err: %.2f', nSecs, nmean_err(nSecs)))
%         hold off
    end
end

%%
figure
plot(nmean_err)
xlabel('num of Beats')
ylabel('Err')
hold on
[m, i] = min(nmean_err);
plot(i,m,'ro','MarkerSize',10)
fprintf('Train RMSE = %0.2f\n', mean_err(i));

param.nSecs = i;

yTrain = TOTyTrain{i};
otTrain = TOTotTrain{i};
eTrain = TOTeTrain{i};
ylimit = [min([otTrain(:); yTrain(:); eTrain(:)]) max([otTrain(:); yTrain(:); eTrain(:)])];
fig = figure;
if k==1
    nStart = nRep-size(otTrain,2)+1;
    subplot(size(ImData,2),1,1); 
    plot(nStart:nRep,otTrain(1,:)); hold on; plot(nStart:nRep,yTrain(1,:),'g'); plot(nStart:nRep,eTrain(1,:),'r'); xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
    legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
    subplot(size(ImData,2),1,2); plot(nStart:nRep,otTrain(2,:)); hold on; plot(nStart:nRep,yTrain(2,:),'g'); plot(nStart:nRep,eTrain(2,:),'r'); xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
    subplot(size(ImData,2),1,3); plot(nStart:nRep,otTrain(3,:)); hold on; plot(nStart:nRep,yTrain(3,:),'g'); plot(nStart:nRep,eTrain(3,:),'r'); xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
    sgtitle(sprintf('num Secss: %i, Err: %.2f', i, nmean_err(i)))
    hold off
else
    yCV = TOTyCV{i};
    otCV = TOTotCV{i};
    eCV = TOTeCV{i};
    nStart = nRep-size([otTrain(1,:) otCV(1,:)],2)+1;
    subplot(size(ImData,2),1,1); 
    plot(nStart:nRep,[otTrain(1,:) otCV(1,:)]); hold on; plot(nStart:nRep,[yTrain(1,:) yCV(1,:)],'g'); plot(nStart:nRep,[eTrain(1,:) eCV(1,:)],'r'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
    legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
    subplot(size(ImData,2),1,2); plot(nStart:nRep,[otTrain(2,:) otCV(2,:)]); hold on; plot(nStart:nRep,[yTrain(2,:) yCV(2,:)],'g'); plot(nStart:nRep,[eTrain(2,:) eCV(2,:)],'r'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
    subplot(size(ImData,2),1,3); plot(nStart:nRep,[otTrain(3,:) otCV(3,:)]); hold on; plot(nStart:nRep,[yTrain(3,:) yCV(3,:)],'g'); plot(nStart:nRep,[eTrain(3,:) eCV(3,:)],'r'); 
    xline(size(otTrain,2)+i,'-','CV','LineWidth',1,'LabelVerticalAlignment','middle'); xlabel('Frame'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
    sgtitle(sprintf('num Secs: %i, Err: %.2f', i, nmean_err(i)))
    hold off
end
saveas(fig,sprintf('NNtrain_Secs%02i_Err%.2f.png',i,nmean_err(i)))

end