function LineData = ReadLineDataV2(fid,iSamples,iChannels)
%%%ReadLineDataV2
%%%DHL.m_ucVersion=2
%%%add 16 byte before each channel
    temp = fread(fid,[2,(iSamples+2)*iChannels],'float32');
    tempC = temp(1,:)+i*temp(2,:);
    tempReshapeC = reshape(tempC,[(iSamples+2),iChannels]);
    LineData = tempReshapeC(3:end,:);