b(1:64,1:64,1:20)=a0(38:101,31:94,1:20)+1;
b2 = sum(a0,3); b0 = b2(38:101,31:94); b0 = lpfilter(b0,0.0618);
for i=1:20, b(:,:,i) = b(:,:,i)./b0; end 
for i = 1:10,
j1=fft2(b(:,:,i)-mean(mean(b(:,:,i))));
j2=fft2(b(:,:,i+10)-mean(mean(b(:,:,i+10))));
jb1=(b(:,:,i));
jb2=(b(:,:,i+10));
ja=real(ifft2(j1.*conj(j2)))/(std(jb1(:))*std(jb2(:))*64^2);
c(i) = max(ja(:));
end
median(c(:))