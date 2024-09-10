% This is about K-L decomposition
addpath 012104_2
skip = 0;
fid = fopen('1456_3381_90_0_32','r');a=0; for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 
for i=1:107,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');
    for i=1:skip, fread(fid,[160,120],'uchar');end
end, fclose(fid);



a0 = reshape_128_128_112103(a,'bicubic'); a=0;asize = size(a0); N = asize(3),
% function K_L_decomp(a)
for i = 1:N, a0(:,:,i) = a0(:,:,i) - mean(mean(a0(:,:,i))); end
for i=1:N,i,pause(0.01)
    for j=1:N
        c(i,j) = sum(sum(a0(:,:,i).*a0(:,:,j) ))/N;
        %c(i,j) = trace(a0(:,:,i)*a0(:,:,j)')/200;
    end
end
'c finished'
[v,d] = eig(c);
'eigenvetor and eigenvalue found'
phi=zeros(128,128,N);
for j=N:-1:1,for i=1:N,phi(:,:,j)=phi(:,:,j)+v(i,j)*a0(:,:,i);end ,end;j = 0;%j,imagesc(phi(:,:,j)),pause(1),end
for i = N:-1:N-50; % collect first 50 decompostion coefficient
    j = j + 1;
    for k = 1:N
        a(j,k) = sum(sum(phi(:,:,i).*a0(:,:,k) ));
    end
end
clear i, clear j, clear k,
