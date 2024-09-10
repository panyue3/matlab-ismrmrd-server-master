
function my_avi2gif(avifile, giffile)
% save the hdr as an avi file

%if ( ~isFileExist(avifile) )
%    return
%end

info = aviinfo(avifile);
M = aviread(avifile);

info
ImageType = info.ImageType;
FramesPerSecond = info.FramesPerSecond;
NumFrames = info.NumFrames;
Width = info.Width;
Height = info.Height;

gifdata = zeros([Height Width 1 NumFrames], 'uint8');

for kk = 1:NumFrames
    gifdata(:, :, :, kk) = M(kk).cdata;
end
size(gifdata)

imwrite(gifdata, gray(256), giffile, 'gif', 'DelayTime', 0.15, 'LoopCount', Inf);
