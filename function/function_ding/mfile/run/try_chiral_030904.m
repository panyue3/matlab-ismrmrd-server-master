% Try to find the chiral asymmetry in hex pattern by Fourier Transformation
% in azimuthal direction at all r and avergae them.

a1=zeros(128,128); a2 =a1;a=0;
fid = fopen('1490_3460_0_0_32','r');a=0; %for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 
'Reading in files ...'
for i=1:20,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
'finished readin, reshaping ...'
a0 = reshape_128_128_112103(a,'bicubic'); a=0;%imagesc(a0(:,:,1)), break
'reshape finished'
x=meshgrid(1:60,1:360);
a1 = 0; a1 =  sum(a0,3); asize = size(a0); %imagesc(a1), break
for i=1:asize(3)  
    b(1:360,1:60)=(xy2rt(a0(:,:,i),64.5,65.5,1:60,0:pi/180:2*pi-0.0001));
    for j=0:359;
        b0(1:360,1:60)=b(1+mod((j):(359+j),360),1:60);
        bsin = 0; bcos = 0;
        for k=4:60
            b1_fft = k*fft(b0(1:360,k));
            bsin(k) = sum(sqrt((real(b1_fft)).^2));
            bcos(k) = sum(sqrt((imag(b1_fft)).^2));
        end
        asym(j+1) = sum(bsin)/sum(bsin+bcos);
    end
    plot(asym), i,pause(2)
    asym0(i) = max(asym(:));
end

mean_asy =mean(asym0),median_asy=median(asym0),std_asy = std(asym0),
