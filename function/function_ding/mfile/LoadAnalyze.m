
function [data, header] = LoadAnalyze(analyzename, realORgrey)

% LoadAnalyze, read an analyze file(.hdr) and output mxArrays
% input: name of analyze file, label of Grey image('Grey') or Real image('Real')
% output:data, header
% Grey: UINT32; Real: single

% reimplement this function using the matlab analyze75read

% [data, header] = LoadAnalyze_mex(analyzename, realORgrey);
% header

info = analyze75info(analyzename);
data = analyze75read(info);

if ( strcmp(realORgrey, 'Grey') == 1 )
    data = uint32(data);
elseif (strcmp(realORgrey, 'Real') == 1)
    data = single(data);
end

header = struct('xsize', 0, 'ysize', 0, 'zsize', 0, ...
        'xvoxelsize', 0.0, 'yvoxelsize', 0.0, 'zvoxelsize', 0.0, 'bytes', 2);
header.xsize = double(info.Dimensions(1));
header.ysize = double(info.Dimensions(2));
header.zsize = double(info.Dimensions(3));
header.xvoxelsize = info.PixelDimensions(1);
header.yvoxelsize = info.PixelDimensions(2);
header.zvoxelsize = info.PixelDimensions(3);
header.bytes = double(info.BitDepth/8);
header;

data(1:header.ysize, : ,:) = data(header.ysize:-1:1, : ,:);