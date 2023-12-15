function image = prompt_plot_predict(OtData, yData, param, info, metadata, logging)

% Check matrix size
if ~isempty(OtData) && ~any(size(OtData) ~= size(yData))
    OtData(1:sum(isnan(yData(:,1))),:) = nan;
    param.predskip(1:sum(isnan(yData(:,1))),2:3) = nan;
    figName = genPlots(OtData, yData, param);

    for ii = 1:numel(figName)
        data = uint16(255 - rgb2gray(imread(figName{ii})))';
        image{ii} = pack_image(data, info);
    end
else
    param.predskip(1:sum(isnan(yData(:,1))),1) = 0;
    ylimit = [min(yData(:))-0.5 max(yData(:))+0.5];
    fig = figure;
    subplot(size(yData,2),1,1); plot(yData(:,1),'k-o');
    xlabel('Time (s)'); ylabel('dX (mm)'); grid('on'); ylim(ylimit);
    legend('prediction','Location','northwest'); legend('boxoff')
    subplot(size(yData,2),1,2); plot(yData(:,2),'k-o');
    xlabel('Time (s)'); ylabel('dY (mm)'); grid('on'); ylim(ylimit);
    subplot(size(yData,2),1,3); plot(yData(:,3),'k-o');
    if isfield(param,'predskip')
        skpIdx = find(param.predskip(:,1));
        hold on; plot(param.predskip(:,2:3),'k--','LineWidth',3); hold off;
    elseif isfield(param,'endExp')
        yline(param.endExp,'k-.','end expiration','LineWidth',3); 
    end
    xlabel('Time (s)'); ylabel('dZ (mm)'); grid('on'); ylim(ylimit);
    sgtitle('Predited Shift')
    hold off
    set(gcf,'Position', [0 0 1200 900])
    figName = fullfile(pwd,'output','Predicted_Shift.png');
    saveas(fig, figName)
    close(fig)
    data = uint16(255 - rgb2gray(imread(figName)))';
    image = pack_image(data, info);
end

end