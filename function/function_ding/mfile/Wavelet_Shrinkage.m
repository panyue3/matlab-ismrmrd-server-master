%a_0 = Wavelet_Shrinkage(a_0, threshold, wname)

function a_0 = Wavelet_Shrinkage(a_0, threshold, wname)

s_0 = size(a_0);
for i=1:s_0(3)
    [swa,swh,swv,swd]=swt2( a_0(:,:,i), 1, wname);
    
    swh1=wthresh(swh, 's', threshold);
    swv1=wthresh(swv, 's', threshold);
    swd1=wthresh(swd, 's', threshold);
    
    %a_0 = iswt2(swa(:,:,end),swh1,swv1,swd1,wname);
    a_0(:,:,i) = iswt2(swa,swh1,swv1,swd1,wname);
end



