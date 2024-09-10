
function hdr2avi(hdrfile, avifile, sizeRatio)
% save the hdr as an avi file

[data, header] = LoadAnalyze(hdrfile, 'Grey');

data = flipdim(data, 1);

minD = min(data(:));
maxD = max(data(:));

newMaxD = 0.5*maxD;

data(find(data(:)>newMaxD)) = newMaxD;

% if ( maxD > 255 )
    data = normalizeImage(double(data)) .* 255;
% end

for kk=1:header.zsize
    
    slice = data(:, :, kk);

    slice = imresize(slice, sizeRatio, 'bicubic');
    
    M(kk) = im2frame(uint8(slice), gray(256));
    
end    

FramesRate = 8;
global frameRate
if ( frameRate ~= -1 )
    FramesRate = frameRate;
end

movie2avi(M, avifile, 'Compression', 'None', 'fps', FramesRate);

[pathstr, name, ext,versn] = fileparts(avifile);
gifname = fullfile(pathstr, [name '.gif']);

height = size(M(1).cdata, 1);
width = size(M(1).cdata, 2);
gifdata = zeros([height width 1 header.zsize], 'uint8');
for kk = 1:header.zsize
    gifdata(:, :, :, kk) = M(kk).cdata;
end
imwrite(gifdata, gray(256), gifname, 'gif', 'DelayTime', 1/FramesRate, 'LoopCount', Inf);