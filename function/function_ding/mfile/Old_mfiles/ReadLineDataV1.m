function LineData = ReadLineDataV1(fid,iSamples,iChannels)
%%%ReadLineDataV1
%%%DHL.m_ucVersion=1

    temp = fread(fid,[2,iSamples*iChannels],'float32');
    tempC = temp(1,:)+i*temp(2,:);
    LineData = reshape(tempC,[iSamples,iChannels]);