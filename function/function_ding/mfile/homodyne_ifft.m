
% Homodyne reconstruciton of partial MRI k-space (Spatial Frequency) dat
% function [m] = homodyne_ifft(pksp, center_k, skip_points)
% pksp: patial k-space data, zero-padded
% center_k: center of k-space position, a number
% skip_point: how many points that are skipped un-sampled
% dim: 
%
%  Reference:
%
%  Noll DC, Nishimura DG, Macovski A. Homodyne Detection in Magnetic 
%  Resonance Imaging.  IEEE Trans. on Medical Imaging 1991; 10(2):154-163
%
%    Written by Edward Brian Welch (edwardbrianwelch@yahoo.com)
%    MRI Research Lab, Mayo Graduate School, November 2001
%   Ding, Yu 2010-10-12, OSUMC, Modified from the code written by Edward Brian Welch
%   (edwardbrianwelch@yahoo.com)
%
function [m] = homodyne_ifft(pksp, center_k, skip_points, dim)
m = 0;
% ERROR CHECKING
if ndims(pksp)~=2 | ~isnumeric(pksp),
    error('PFFT operates on two-dimensional numerical data');
    return
end

s0 = size(pksp);
if dim==2, pksp = pksp'; end % make the partial F in the first dim.

% Convert data into hybrid space by inverse FFT along FE dir.
% for better numerical accuracy.
%pksp = ifft(pksp,[],2);

% Frequency Encode direction is assumed to be the longer direction
[Npp Nf] = size(pksp);

% Number of phase encodes in the full k-space
%Np = 2^nextpow2(Npp+1);
Np = Npp;
% Number of high frequency phase encodes
NH = Np-2*skip_points;

% NUmber of low frequency phase encodes
%NL = Npp - NH;
NL = skip_points; 

% Row indices of high and low frequency lines
LFind = NL+1:NH+NL; % This is the high-frequency part
HFind = (NH+NL+1):(Np);

% Create weighting window
%
% It multiplies all un-partnered high frequency lines by 2.0
% Low frequency lines are multiplied by a ramp that approaches 
% zero at the zero-padded edge of k-space.  The weighting
% factors of two partnered low frequency lines should have a 
% sum of 2.0
w = zeros(Np,1);
w(HFind) = 2;
%rstep = 2/(NL+1);
rstep = 2/(NH+1);
%w(LFind) = [(2-rstep):-rstep:rstep];
w(LFind) = [rstep:rstep:(2-rstep)];% figure(4), plot(w)

% Create weighted partial k-space
HFksp = zeros(Np,Nf);
HFksp(1:Npp,:)=pksp;
HFksp = HFksp.*repmat(w,1,Nf); %figure(3), imagesc(abs(repmat(w,1,Nf)))

% Create Low Frequency k-space 
LFksp = zeros(Np,Nf);
LFksp(LFind,:) = pksp(LFind,:);

% Low frequency image
%Rc = ifft(LFksp,[],1);
Rc = fftshift(ifft2(ifftshift(LFksp))); %figure(1), imagesc(abs(LFksp).^0.25), axis image, 

% Unsynchronous image
%Ic = ifft(HFksp,[],1);
Ic = fftshift(ifft2(ifftshift(HFksp))); %figure(2), imagesc(abs(HFksp).^0.25), axis image, pause

% Synchronous image
Is = Ic.*exp(-i*angle(Rc)); %figure(3), imagesc([angle(Rc), medfilt2(angle(Rc))]), pause,
%Is = Ic.*exp(-i*medfilt2(angle(Rc)));
% Demodulated image
m = real((Is)); %figure(1), imagesc(abs([real((Is)), imag((Is))]).^0.25), colorbar, pause
m = Ic; % do not do anything
if dim==2, m = m'; end % correct image orientation.













