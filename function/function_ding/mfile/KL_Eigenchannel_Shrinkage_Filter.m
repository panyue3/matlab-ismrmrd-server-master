
% function a_r = KL_Eigenchannel_Shrinkage_Filter(a_0, Noise_std, R, Cutoff)
% a_0:          3-D input image series 
% Noise_std:    Noise std 
% R:            Acceleration Rate 
% Cutoff:       Eigenimage Cutoff

function a_r = KL_Eigenchannel_Shrinkage_Filter(a_0, varargin)

s = size(a_0); 
a_r = zeros(s);
if length(s) ~= 3
    'KL_Eigenchannel_Shrinkage_Filter: Error! a_0 must be 3-D',
    return
end
[a_0, V, D] = KL_Eigenimage(a_0); %diag(D)', figure(1), semilogy(diag(D), 'o'), pause, 

Cutoff = 0;
if nargin == 1
    N_std_0 = sqrt( D(1,1));
    FOV_reduction_factor = 2;
elseif nargin == 2
    N_std_0 = varargin{1};
    FOV_reduction_factor = 2;
elseif nargin == 3
    N_std_0 = varargin{1};
    FOV_reduction_factor = varargin{2};
elseif nargin == 4
    N_std_0 = varargin{1};
    FOV_reduction_factor = varargin{2};
    Cutoff = varargin{3};
end

%{ 'med-Eig', median(diag(D)), 'N-var', N_std_0^2 }
% Noise Level is estimated from the 
noise_std = ( 1.0 * N_std_0); 
% Shrinkage Filter
a_I = a_0;
a_I(:,:,1:end-FOV_reduction_factor) = shrinkage(a_0(:,:,1:end-FOV_reduction_factor), noise_std);
%for i=1:s(3), imagesc(sqrt(abs([a_I(:,:,i), a_0(:,:,i)]))), axis image, title(num2str(i)), pause, end
% Find noise only eigen-images and make them zero.
N_r = 2;
if Cutoff
    N_r = Cutoff;
else
    for i=2:s(3),
        if D(i, i) > 1.4* N_std_0^2, N_r = i-1; break, end
    end
end
N_r = N_r;
a_I(:,:,1:N_r) = 0;

b = (reshape(a_I, [s(1)*s(2),s(3)] ));
a_r = (reshape(b*V', [s(1),s(2),s(3)] ) ) ;






