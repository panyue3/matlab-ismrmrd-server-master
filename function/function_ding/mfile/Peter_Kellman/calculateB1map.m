function [b1map] = calculateB1map(input, params);
% function [b1map] = calculateB1map(input, params);
%
% this function estimates the relative b1-maps (complex coil sensitivity profiles).
% the magnitude of the b1-maps are relative to the root-sum-of squares combined magnitude.
% the phase of the b1-maps are relative to the first coil. The algorithm for computing
% sensitivities is based on eigenvector filter approach per Walsh, et al. MRM. 2000;43:682-90.
%
% Inputs:
%    input(y,x,coil) is multi-dimensional array containing complex multi-coil images
%    params is structure containing: 
%         params.b1map.spatial_smoothing = 0,1 flag to turn smoothing on or off
%         params.b1map.N_smooth = N, integer determining square kernel size (NxN)
% Output:
%    b1map(y,x,coil) is the multi-dimensional array containing the complex b1-map estimate

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************


[rows,cols,ncoils]=size(input);
if nargin==1; % set defaults
    params.b1map.spatial_smoothing = 1;
    params.b1map.coilmap_smoothing_blocksize = 7;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % normalize by root sum of squares magnitude
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mag = rss(input,3);
s_raw=input./repmat(mag + eps,[1 1 ncoils]); % add epsilon to avoid division by 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute sample correlation estimates at each pixel location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rs=correlation_matrix(s_raw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply spatial smoothing to sample correlation estimates (NxN convolution)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_smooth=params.b1map.coilmap_smoothing_blocksize;
if params.b1map.spatial_smoothing==1
	h_smooth=ones(N_smooth)/(N_smooth^2); % uniform smoothing kernel
	for m=1:ncoils
		for n=1:ncoils
		    Rs(:,:,m,n)=conv2(Rs(:,:,m,n),h_smooth,'same');
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute dominant eigenvectors of sample correlation matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[b1map,lambda]=eig_powermethod(Rs); % using power method

return





