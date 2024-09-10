function [Rs]=correlation_matrix(s);
% function [Rs]=correlation_matrix(s);
%
% function correlation_matrix calculates the sample correlation matrix (Rs) for
% each pixel of a multi-coil image s(y,x,coil)
%
% input:
%    s   complex multi-coil image s(y,x,coil)
% output:
%    Rs  complex sample correlation matrices, Rs(y,x,coil,coil)

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************


[rows,cols,ncoils]=size(s);
Rs=zeros(rows,cols,ncoils,ncoils); % initialize sample correlation matrix to zero
for i=1:ncoils
    for j=1:i-1
		Rs(:,:,i,j)=s(:,:,i).*conj(s(:,:,j));
		Rs(:,:,j,i)=conj(Rs(:,:,i,j)); % using conjugate symmetry of Rs
    end
	Rs(:,:,i,i)=s(:,:,i).*conj(s(:,:,i));
end

return