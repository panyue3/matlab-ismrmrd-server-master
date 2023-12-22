function figName = genPlots(otData, yData, param, idx)

eData = otData - yData;
ylimit = [min([otData(:); yData(:); eData(:)])-0.5 max([otData(:); yData(:); eData(:)])+0.5];
if nargin > 3
    otCV = otData(idx.CV,:);
    yCV = yData(idx.CV,:);
    eCV = otCV - yCV;
end

fig = figure;
subplot(size(otData,2),1,1); plot(otData(:,1),'k'); hold on; plot(yData(:,1),'k--'); plot(yData(:,1),'ko'); plot(eData(:,1),'k:'); 
xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);  xlim([0 size(yData,1)])
if nargin > 3; plot(idx.CV,eCV(:,1),'bx','MarkerSize',10); end
legend('data', 'prediction', 'error','Location','northwest'); legend('boxoff')
subplot(size(otData,2),1,2); plot(otData(:,2),'k'); hold on; plot(yData(:,2),'k--'); plot(yData(:,2),'ko'); plot(eData(:,2),'k:'); 
xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);  xlim([0 size(yData,1)])
if nargin > 3; plot(idx.CV,eCV(:,2),'bx','MarkerSize',10); end
subplot(size(otData,2),1,3); plot(otData(:,3),'k'); hold on; plot(yData(:,3),'k--'); plot(yData(:,3),'ko'); plot(eData(:,3),'k:'); 
if nargin > 2 
    if isfield(param,'predskip'); hold on; plot(param.predskip(:,2:3),'k--','LineWidth',3); hold off
    elseif isfield(param,'endExp'); yline(param.endExp,'k-.','end expiration','LineWidth',3); end
end
xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);  xlim([0 size(yData,1)])
if nargin > 3; plot(idx.CV,eCV(:,3),'bx','MarkerSize',10); end
if nargin > 3
    err_train = 10 * log10(sum(eData(idx.Train,:).^2,'all','omitnan') / sum(otData(idx.Train,:).^2,'all','omitnan'));
    err_cv = 10 * log10(sum(eData(idx.CV,:).^2,'all','omitnan') / sum(otData(idx.CV,:).^2,'all','omitnan'));
    sgtitle(sprintf('Train Err: %.2f, CV Err: %.2f', err_train, err_cv))
    figName{1} = fullfile(pwd,'output','Train_Result.png');
else
    err = 10 * log10(sum(eData.^2,'all','omitnan') / sum(otData.^2,'all','omitnan'));
    sgtitle(sprintf('Test Err: %.2f', err))
    figName{1} = fullfile(pwd,'output','Test_Result.png');
end
hold off
set(gcf,'Position', [0 0 1200 900])
saveas(fig, figName{1})
close(fig)  

fig = figure;
hold on
if nargin > 3
    scatter(yData(:,1),otData(:,1),100,'k.');
    scatter(yData(:,2),otData(:,2),100,'k.');
    scatter(yData(:,3),otData(:,3),100,'k.');
    scatter(yCV(:,1),otCV(:,1),100,'k^');
    scatter(yCV(:,2),otCV(:,2),100,'kdiamond');
    scatter(yCV(:,3),otCV(:,3),100,'ko');
else
    scatter(yData(:,1),otData(:,1),'k+');
    scatter(yData(:,2),otData(:,2),'kx');
    scatter(yData(:,3),otData(:,3),'ko');
end
xlabel("Predicted Shift")
ylabel("Actual Shift")
xlim(ylimit)
ylim(ylimit)
plot(ylimit, ylimit, "r--")
if nargin > 3
    legend('Train','','','dX','dY','dZ','','Location','best')
    figName{2} = fullfile(pwd,'output','Train_Predit.vs.Actual.png');
else
    legend('dX','dY','dZ','','Location','best')
    figName{2} = fullfile(pwd,'output','Test_Predit.vs.Actual.png');
end
set(gcf,'Position', [0 0 900 900])
saveas(fig, figName{2})
close(fig)

fig = figure;
hold on
if nargin > 3
    scatter(mean([yData(:,1),otData(:,1)],2),eData(:,1),100,'k.');
    scatter(mean([yData(:,2),otData(:,2)],2),eData(:,2),100,'k.');
    scatter(mean([yData(:,3),otData(:,3)],2),eData(:,3),100,'k.');
    scatter(mean([yCV(:,1),otCV(:,1)],2),eCV(:,1),80,'k^');
    scatter(mean([yCV(:,2),otCV(:,2)],2),eCV(:,2),80,'kdiamond');
    scatter(mean([yCV(:,3),otCV(:,3)],2),eCV(:,3),80,'ko');
else
    scatter(mean([yData(:,1),otData(:,1)],2),eData(:,1),50,'k^');
    scatter(mean([yData(:,2),otData(:,2)],2),eData(:,2),50,'kdiamond');
    scatter(mean([yData(:,3),otData(:,3)],2),eData(:,3),50,'ko');
end
xlabel("Mean of Actual and Predicted Shift")
ylabel("Actual Shift - Predicted Shift")
yline(mean(eData,'all','omitnan'),'LineWidth',2)
yline(mean(eData,'all','omitnan')+std(eData,[],'all','omitnan'), '--','LineWidth',2)
yline(mean(eData,'all','omitnan')-std(eData,[],'all','omitnan'), '--','LineWidth',2)
xlim(ylimit)
ylim([-max(abs(ylimit)) max(abs(ylimit))])
if nargin > 3
    legend('Train','','','dX','dY','dZ','','','','Location','best')
    figName{3} = fullfile(pwd,'output','Train_Bland-Altman.png');
else
    legend('dX','dY','dZ','','','','Location','best')
    figName{3} = fullfile(pwd,'output','Test_Bland-Altman.png');
end
set(gcf,'Position', [0 0 800 600])
saveas(fig, figName{3})
close(fig)

end