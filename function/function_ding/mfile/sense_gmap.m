% gmap = sense_gmap(channelsensitivity, num_kspace_ln, noise_cov)
% channelsensitivity: full resolution images for each channel 3D data
% num_kspace_ln: number of k-space lines in wrapped images
% noise_cov: noise covariance matrix


function gmap = sense_gmap(channelsensitivity, num_kspace_ln, noise_cov) 

Npe_seg = num_kspace_ln;
[Nfe, Npe, trash] = size(channelsensitivity);
Rr = (Npe/Npe_seg); 

for pe=1:Npe_seg
   for i=1:Nfe
       if((pe+Npe_seg*(Rr-1))>Npe)
           delt=(pe+Npe_seg*(Rr-1))-Npe;
       else
           delt=0;
       end

      s1=squeeze(channelsensitivity(i,pe:Npe_seg:(pe-delt+Npe_seg*(Rr-1)),:));
      s=transpose(s1);
      %I_mat=squeeze(overlapped_img(i,pe,:)); % Ding 2009-05-05
      %recon(i,pe:Npe_seg:(pe-delt+Npe_seg*(Rr-1))) = transpose((inv(s'*s)*s'*I_mat)); % Ding 2009-05-05
      tmp = pinv(s'*pinv(noise_cov)*s).*(s'*pinv(noise_cov)*s); tmp = sqrt(abs(diag(tmp))); % add noise cov matrix Ding 2009-05-05
      [l trash]=size(tmp);
      if (l ~= length(pe:Npe_seg:(pe+Npe_seg*(Rr-1))))
         tmp(l+1:length(pe:Npe_seg:(pe+Npe_seg*(Rr-1))),:)=0;
      end
      gmap(i,pe:Npe_seg:(pe+Npe_seg*(Rr-1)))= tmp';
  end 
end





