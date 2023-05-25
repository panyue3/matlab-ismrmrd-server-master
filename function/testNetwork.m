function param = testNetwork(imdata, ptdata, net)

param = ptdata.param;
% ptdata.data = (ptdata.data - param.M) ./ param.SD;
numRep = size(imdata.shiftvec,1);
% Pack PT and Disp data into NN input and output arrays
InData = [];
nBeats = sum(ptdata.time(param.pk)<param.nSecs);
InData{numRep-nBeats} = [];
for ii = 1:(numRep-nBeats)
    InData{ii} = ptdata.data(param.pk(nBeats+ii)-param.numPT*param.nSecs+1:param.pk(nBeats+ii),:)';
end
OtData = imdata.shiftvec(nBeats+1:numRep,:);

yData = predict(net,InData,'MiniBatchSize',1);
eData = OtData - yData;
err = 10 * log10(sum(eData.^2,'all') / sum(OtData.^2,'all'));

ylimit = [min([OtData(:); yData(:); eData(:)]) max([OtData(:); yData(:); eData(:)])];
fig = figure;
subplot(size(imdata.shiftvec,2),1,1); plot(nBeats+1:numRep,OtData(:,1),'k'); hold on; plot(nBeats+1:numRep,yData(:,1),'k--'); plot(nBeats+1:numRep,eData(:,1),'k:'); 
xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
subplot(size(imdata.shiftvec,2),1,2); plot(nBeats+1:numRep,OtData(:,2),'k'); hold on; plot(nBeats+1:numRep,yData(:,2),'k--'); plot(nBeats+1:numRep,eData(:,2),'k:'); 
xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
subplot(size(imdata.shiftvec,2),1,3); plot(nBeats+1:numRep,OtData(:,3),'k'); hold on; plot(nBeats+1:numRep,yData(:,3),'k--'); plot(nBeats+1:numRep,eData(:,3),'k:'); 
xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
sgtitle(sprintf('Test Err: %.2f', err))
hold off
set(gcf,'Position', [0 0 1200 900])
param.figName{1} = fullfile(pwd,'output','Test_Result.png');
saveas(fig, param.figName{1})
close(fig)  

fig = figure;
hold on
scatter(yData(:,1),OtData(:,1),'k+');
scatter(yData(:,2),OtData(:,2),'kx');
scatter(yData(:,3),OtData(:,3),'ko');
xlabel("Predicted Shift")
ylabel("Actual Shift")
m = min(OtData,[],'all');
M=max(OtData,[],'all');
xlim([m M])
ylim([m M])
plot([m M], [m M], "r--")
legend('dX','dY','dZ','','Location','Best')
param.figName{2} = fullfile(pwd,'output','Test_Predit.vs.Actual.png');
saveas(fig, param.figName{2})
close(fig)

end