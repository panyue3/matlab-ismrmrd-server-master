
function avi2gif(avifile, giffile, rbglist, indlist)
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

if ( strcmp(ImageType, 'truecolor') )
    
    disp('transform the rgb color to ind color')

    num = size(rbglist, 1);
    if ( num > 0 )
        for kk = 1:NumFrames

            indexes = cell(num, 1);
            slice = double(M(kk).cdata);
            M(kk).cdata = sum(double(M(kk).cdata), 3);
            M(kk).cdata = M(kk).cdata / 3;

            for pp = 1:num
                indexes{pp} = find(slice(:, :, 1)==rbglist(pp, 1) ...
                    & slice(:, :, 2)==rbglist(pp, 2) ...
                    & slice(:, :, 3)==rbglist(pp, 3));

    %             indexes{pp} = find(abs(slice(:, :, 1)-rbglist(pp, 1))<0.5 ...
    %                 & abs(slice(:, :, 2)-rbglist(pp, 2))<0.5 ...
    %                 & abs(slice(:, :, 3)-rbglist(pp, 3))<0.5);

                % only for red
    %             indexes{pp} = find(slice(:, :, 1)>slice(:, :, 2) ... 
    %                 & slice(:,:,1)>slice(:, :, 3));

                M(kk).cdata(indexes{pp}) = indlist(pp);

            end
            M(kk).cdata = uint8(M(kk).cdata);
            M(kk).colormap = gray(256);
        end
    end
end

colormap = M(1).colormap;
for kk = 1:NumFrames
    gifdata(:, :, :, kk) = M(kk).cdata;
end

global frameRate
if ( frameRate ~= -1 )
    FramesPerSecond = 1/frameRate;
end
imwrite(gifdata, colormap, giffile, 'gif', 'DelayTime', FramesPerSecond, 'LoopCount', Inf);
