addpath 032404

for n=1:3,
    if n == 1, fname = '2250_5224_90_0_4';elseif n==2,fname='2290_5317_90_0_4';else fname='2340_5433_90_0_4';end
    fid = fopen(fname,'r');
    for i=1:300, a(1:160,1:120,i) = fread(fid,[160,120],'uchar');end, fclose(fid);
    a0 = reshape_128_128_112103(a,'bicubic');
    clear a;
    a_size = size(a0);
    for i=1:a_size(3), a = a0(:,:,i); distortion_field(a), M(i)=getframe;pause(0.1);end
    fname_mov = sprintf('%s_distort_field_mov',fname);
    movie2avi(M,fname_mov,'FPS',12); 
    if n==1;for i=1:a_size(3),c2250_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end; end
    if n==2;for i=1:a_size(3),c2290_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end; end
    if n==3;for i=1:a_size(3),c2340_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end; end
    clear a0;
end
rmpath 032404
addpath 121303

for n=1:3,
    if n == 1, fname = '1450_3367_90_0_32';elseif n==2,fname='1454_3376_90_0_32';else fname='1458_3385_90_0_32';end
    fid = fopen(fname,'r');
    for i=1:300, a(1:160,1:120,i) = fread(fid,[160,120],'uchar');end, fclose(fid);
    a0 = reshape_128_128_112103(a,'bicubic');
    clear a;
    a_size = size(a0);
    for i=1:a_size(3), a = a0(:,:,i); distortion_field(a), M(i)=getframe;pause(0.1);end
    fname_mov = sprintf('%s_distort_field_mov',fname);
    movie2avi(M,fname_mov,'FPS',12); 
    if n==1;for i=1:a_size(3),c1450_121303_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end, end
    if n==2;for i=1:a_size(3),c1454_121303_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end ,end
    if n==3;for i=1:a_size(3),c1458_121303_1_300(i)=min(Compare_Chirality(a0(:,:,i)));end ,end
    clear a0;
end




