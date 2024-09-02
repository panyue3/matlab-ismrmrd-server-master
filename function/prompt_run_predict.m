function shiftvector = prompt_run_predict(ptGroup, ecgGroup, net, param, metadata, logging)

if isempty(ptGroup) && isempty(ecgGroup)
    % Set up data for dummy prediction
    InData = zeros(param.numVCha*2, param.numPT*param.nSecs);
else
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
    ptdata.rawtime = (0:numel(ptdata.isvalid)-1)'*500*10^-6 + double(ptGroup{find(ncha == mode(ncha),1)}.head.time_stamp - param.startTime)*2.5*10^-3;

    % Extract ecg data
    if ecgGroup{1}.head.waveform_id == 0
        ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,5)==16384, ecgGroup, 'UniformOutput', false)');
    else
        ecgdata.trigger = cell2mat(cellfun(@(x) x.data(:,2)==2048, ecgGroup, 'UniformOutput', false)');
    end
    ecgdata.nSamples = sum(cell2mat(cellfun(@(x) x.head.number_of_samples, ecgGroup, 'UniformOutput', false)'));
    ecgdata.time =  double(uint32 (1:ecgdata.nSamples) + ecgGroup{1}.head.time_stamp - param.startTime)'*2.5*10^-3;
    ecgdata.trigger(ecgdata.time==0) = [];
    ecgdata.time(ecgdata.time==0) = [];
    ecgdata.nSamples = numel(ecgdata.trigger);

    % Process PT
    [ptdata.data, ptdata.time] = processPT(ptdata, logging, param);

    % Find trigger indices
    ntrigs = find(ecgdata.trigger);
    ecgdata.trigger(ntrigs(find(diff(ecgdata.time(ecgdata.trigger)) < 0.5)+1)) = false;

    time_mx = ptdata.time - ecgdata.time(ecgdata.trigger).';
    time_mx(time_mx>0) = nan;
    [~, param.pk] = max(time_mx, [], 1,'omitnan');

    % Pack PT into NN input array
    temp = ptdata.data(param.pk(end)-param.numPT*param.nSecs+1:param.pk(end),:);
    InData = ((temp - mean(temp)) ./ std(temp))';
end

shiftvector = predict(net,InData,'MiniBatchSize',1);

end