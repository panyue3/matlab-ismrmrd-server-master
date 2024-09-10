function data = ephantom2(dim,tfun)
% Generates a moving 2D virtual phantom
%
% data = ephantom2(dim,tfun);
%
% data: k-space data.  Assumes FOV = 1 in all dimensions
% dim = [nx ny nt]: size of the data
% tfun (optional): a vector of length nt with numbers in the range -1 to 1
%                  that indecates the variation of the parameters (par +
%                  tfun*delta_par).  If not present, defaults to a sinusoide.
%
% Pablo Irarrazaval
% 25-11-03 Creation
% 27-11-03 Adds defined time function. Modifies calling prototype.
% 14-07-04 Fix small bug in limits of kx and ky
  
USAGE_STR = 'Usage: data = ephantom2(dim,{tfun})';

% check parameters
% ----------------

% check input arguments
if (nargin<1)|(nargin>2),
  error(sprintf('%s',USAGE_STR));
end;
% check dim
if length(dim)~=3,
  error(sprintf('%s\ndim should be [nx ny nt]',USAGE_STR));
end;
% check tfun
if nargin==1,
  tfun = sin(((1:dim(3))-1)*2*pi/dim(3));
else
  if length(tfun)~=dim(3),
    error(sprintf('%s\ntfun should have length equal to dim(3)',USAGE_STR));
  end;
end;


% prepare internal variables
% --------------------------
nx_min = -floor((dim(1)-1)/2)-1;
nx_max = ceil((dim(1)-1)/2)-1;
ny_min = -floor((dim(2)-1)/2)-1;
ny_max = ceil((dim(2)-1)/2)-1;
kx = (nx_min:nx_max)'*ones([1 dim(2)]);     %'
ky = ones([dim(1) 1])*(ny_min:ny_max);

% generates the k-space data for each frame
% -----------------------------------------
data = zeros(dim);
for time = 1:dim(3),
  frame = zeros(dim(1:2));
  % First I'll progrma the static part     %'
  frame = frame + 0.7*ephantom2_elipse(kx,ky,...
				   [0 0 70 90]/100,...
				   [0 0 0 0]/100,...
 				   tfun(time));
% 26-4-07: commented out by shaihan to have static background
% also added factor of 0.7 above to downweight background
%   frame = frame - ephantom2_elipse(kx,ky,...
% 				   [0 0 65.5 87.5]/100,...
% 				   [0 0 0 0]/100,...
% 				   tfun(time));
  frame = frame - 0.7*ephantom2_elipse(kx,ky,...
				   [-18 18 10 10]/100,...
				   [0 0 0 0]/100,...
				   tfun(time));
  frame = frame + 0.7*ephantom2_rectangle(kx,ky,...
					  [-5 -34 10 10]/100,...
					  [0 0 0 0]/100,...
					  tfun(time));
  % Now the moving bits
  frame = frame + 0.8*ephantom2_elipse(kx,ky,...
				   [-3.25 -10 43 30]/100,...
				   [2.5 0 7 0]/100,...
				   tfun(time));
  frame = frame + ephantom2_elipse(kx,ky,...
 				   [-12.05 -10 12 16]/100,...
 				   [3.5 0 3 0]/100,...
 				   tfun(time));
  frame = frame + ephantom2_elipse(kx,ky,...
 				   [8.0 -10 9 15]/100,...
 				   [1.85 0 2 0]/100,...
 				   tfun(time));
  frame = frame + 0.6*ephantom2_elipse(kx,ky,...
 				   [5 20.5 20 25]/100,...
 				   [0 -1 0 -5]/100,...
 				   tfun(time));
 data(:,:,time) = frame;
end;

return;

