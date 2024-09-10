function [ I ] = getImage( varargin )
%GETIMAGE returns the 2-D matrix of the image. The values are of type
%double and between 0 and 1.
% It can take 1,2, or 3 parameters
% 1st parameter - file name
% 2nd parameter - max

%  Detailed explanation goes here

[fileName, mag_or_vel, alias_adjust, max_intensity] = parse_inputs(varargin{:});
I=dicomread(fileName);
I=double(I);

if(strcmpi(mag_or_vel,'vel'))
    
    % a new variable is used for clarity of expression.
    v=alias_adjust;
    if v > 0, I(find(I<v)) = I(find(I<v)) + 4096;end
    if v < 0, I(find(I > 4095+v)) = I(find(find(I > 4095+v))) - 4096;end 
end

if ~isempty(max_intensity)
  I = I/max_intensity;
end

%resizing will not be done  as it affects pixel dimensions and hence
%distance from aortic root
%I = imresize(I,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [fileName, mag_or_vel, alias_adjust, max_intensity] = parse_inputs(varargin)
max_intensity=[];

if(nargin == 3)
    fileName = varargin{1};
    mag_or_vel = varargin{2};
    alias_adjust = varargin{3};
elseif(nargin==4)
    fileName = varargin{1};
    mag_or_vel = varargin{2};
    alias_adjust = varargin{3};
    max_intensity = varargin{4};
else
    disp('*******************************************');
    disp('Incorrect use of the function getImage. Atleast 3 and at the most 4 parameters must be provided');
    disp('*******************************************');
end