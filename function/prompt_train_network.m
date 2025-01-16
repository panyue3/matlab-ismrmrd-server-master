function image = prompt_train_network(imdata, ptdata, info, metadata, logging)

% Find correlation between ptdata and imdata
ptdata.param.cor = sign(corr(imdata.shiftvec(:,3),ptdata.data(ptdata.param.pk,:)));
ptdata.param.cor(isnan(ptdata.param.cor)) = 1;
ptdata.data = ptdata.data * diag(ptdata.param.cor);

% Run training
logging.info("Training network...")
[net, param] = runTraining(imdata, ptdata, logging);
param.coils = {metadata.acquisitionSystemInformation.coilLabel.coilName}';
[~, idx] = sort(param.coils);
param.coils = param.coils(idx);

% Save training data
tmp = [split(metadata.measurementInformation.frameOfReferenceUID,'.'); split(metadata.measurementInformation.measurementID,'_')];
filename = sprintf("train_%s.%s_%s.mat", tmp{11}, tmp{end}, metadata.measurementInformation.protocolName);
if ispc
    filename = fullfile(pwd,'output',filename);
elseif isunix
    filename = fullfile('/tmp/share/prompt',filename);
end
save(filename,'imdata', 'ptdata','net', 'param', 'info','metadata');

% Save figure to output folder
fig = figure;
for i=1:min([ptdata.param.numVCha 4])
    nexttile; hold on;
    plot(ptdata.time, ptdata.data(:,i)-mean(ptdata.data(:,i)),'k')
    plot(ptdata.time, ptdata.data(:,i+ptdata.param.numVCha)-mean(ptdata.data(:,i+ptdata.param.numVCha)),'k--')
    title(sprintf('PT channel %i',i)); xlim([0 max(ptdata.time)]); hold off
end
lgd = legend('Real','Imag'); lgd.Layout.Tile = 'south'; lgd.NumColumns = 2;
set(gcf,'Position', [0 0 1200 900])
param.figName{end+1} = fullfile(pwd,'output','Train_PT.png');
saveas(fig, param.figName{end})
close(fig)

for ii = 1:numel(param.figName)
    data = uint16(255 - rgb2gray(imread(param.figName{ii})))';
    image{ii} = pack_image(data, info);
end

end