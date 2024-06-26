function ptdata = prompt_process_waveform_test(ptGroup, ecgGroup, metadata, logging, param)

% Check all pt samples have same number of channels
ncha = cellfun(@(x) x.head.channels, ptGroup);

% Extract pt data
if ecgGroup{1}.head.waveform_id == 0
    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(:,1:end-1), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)');
    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:end,end), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)'));
else
    ptdata.rawdata = cell2mat(cellfun(@(x) x.data(1:10,1:end-1), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)');
    ptdata.isvalid = logical(cell2mat(cellfun(@(x) x.data(1:2:10,end), ptGroup(ncha == mode(ncha)), 'UniformOutput', false)'));
end
ptdata.rawdata = reshape(typecast(ptdata.rawdata(:),'single'),[],mode(ncha)-1);
ptdata.rawdata = ptdata.rawdata(1:2:end,:) + ptdata.rawdata(2:2:end,:)*1i;
ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6;
% Extract ecg data
if ecgGroup{1}.head.waveform_id == 0
    ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
else
    ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,2)==2048, ecgGroup, 'UniformOutput', false)');
end
ecgdata.nSamples = sum(cell2mat(cellfun(@(x) x.head.number_of_samples, ecgGroup, 'UniformOutput', false)'));
ecgdata.time =  double(uint32 (1:ecgdata.nSamples) + ecgGroup{1}.head.time_stamp - ptGroup{find(ncha == mode(ncha),1)}.head.time_stamp)'*2.5*10^-3;
ecgdata.trigger(ecgdata.time==0) = [];
ecgdata.time(ecgdata.time==0) = [];
ecgdata.nSamples = numel(ecgdata.trigger);
ecgdata.medianRR =  median(diff(ecgdata.time(ecgdata.trigger)));

% Process PT
[ptdata.data, ptdata.time, ptdata.param] = processPT(ptdata, logging, param);

% Check if trigger number matches measurement number
if any(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements')) && metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements'))).value ~= sum(ecgdata.trigger)
    nImg = metadata.userParameters.userParameterLong(find(strcmp({metadata.userParameters.userParameterLong.name}, 'NumberOfMeasurements'))).value;
    logging.debug('Number of trigger and number of measurement did not match, # meas: %i, # trigs: %i', nImg, sum(ecgdata.trigger))
    t_fst_rf = ptdata.rawtime(~ptdata.isvalid);
    t_fst_rf = [t_fst_rf(1); t_fst_rf([0; diff(t_fst_rf)] > 0.5*ecgdata.medianRR)];

    if nImg < sum(ecgdata.trigger) % extra trigger
        t_trigs = ecgdata.time(ecgdata.trigger);
        time_mx = t_fst_rf - t_trigs.';
        time_mx(time_mx<0) = nan;
        t_delay= round(min(time_mx, [], 1,'omitnan'), 2);
        logging.debug('Deleting %i triggers.', sum(t_delay ~= mode(t_delay)))
        ecgdata.trigger(ecgdata.time == t_trigs(t_delay ~= mode(t_delay))) = false;
    end

    if nImg > sum(ecgdata.trigger) % missing trigger
        t_trigs = ecgdata.time(ecgdata.trigger);
        time_mx = t_fst_rf - t_trigs.';
        time_mx(time_mx<0) = nan;
        t_delay = round(min(time_mx, [], 2,'omitnan'), 2);
        misIdx = find(t_delay~=mode(t_delay));
        logging.debug('Inserting %i triggers.', numel(misIdx))
        for ii=1:numel(misIdx)
            [~,idx] = min(abs(ecgdata.time - (t_fst_rf(misIdx(ii))-median(min(time_mx, [], 2,'omitnan')))));
            ecgdata.trigger(idx) = true;
        end
    end
end

% Find trigger indices
time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
time_mx(time_mx>0) = nan;
[~, ptdata.param.pk] = max(time_mx, [], 1,'omitnan');
ptdata.ecgdata = ecgdata;

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
figname = fullfile(pwd,'output','Test_PT.png');
saveas(fig, figname)
close(fig)

end