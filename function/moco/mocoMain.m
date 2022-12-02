% close all;
% clear all;

% load exampleData
% n = size(ref);
% ref = phantom('modified shepp-logan', n);
% align = imrotate(ref,1);
% align = circshift(ref, [0,-0]);
% ref = imrotate(ref, 5); ref = ref(5:end-5,5:end-5);

B = im;
B = 10*B/max(B(:));
refID = 1;
%R = B(:,:,refID);
param.mocoReg = 1; % Moco regularization
[Dx,Dy, DxInv, DyInv] = mocoDisp(B, refID, param.mocoReg);
Am  = mocoApply(B, Dx, Dy);
Amm = mocoApply(Am, DxInv, DyInv);

x_xreg = cat(2, B, Am);
implay(0.1*x_xreg);

%%
%figure; for j=1:10, for i=1:size(x_xreg,3), imagesc(abs(squeeze(x_xreg(:,:,i))),[0, max(abs(B(:)))]); axis('image','off'); colormap(gray); pause(0.08); end, end

%%
% figure; for j=1:1, for i=1:size(Am,3), imagesc(cat(2,abs(squeeze(Amm(:,:,i))), abs(B(:,:,i))),[0, 0.25*max(abs(B(:)))]); axis('image','off'); colormap(gray); pause(0.12); end, end

%%
% figure; for j=1:1, for i=1:size(Am,3), imagesc(abs(squeeze(Amm(:,:,i)-B(:,:,i))),[0, 0.1*max(abs(B(:)))]); axis('image','off'); colormap(gray); title([num2str(i)]);pause(0.5); end, end
% [y,x] = meshgrid(-n(2)/2:n(2)/2-1, -n(1)/2:n(1)/2-1);
% xq = x + Dx(:,:,i);
% yq = y + Dy(:,:,i);
% ARm = interp2(y,x,a,yq,xq,'spline');
% 
% xq = x + DxInv(:,:,i);
% yq = y + DyInv(:,:,i);
% ARmm = interp2(y,x,ARm,yq,xq,'spline');
% ARmm(isnan(ARmm)) = 0;
% 
%%
% mx = max(abs(R(:)));
% a = B(:,:,alnID);
% figure;
% subplot(2,2,1); imagesc(abs(a), [0, mx]); axis('image'); colormap(gray); title('to align');
% % subplot(2,3,2); imagesc(abs(Amm),[0,mx]);axis('image'); colormap(gray); title(['re-aligend (Sie), SNR: ' num2str(-20*log10(norm(a-Amm)/norm(a(:))))]);
% subplot(2,2,2); imagesc(abs(Amm(:,:,alnID)),[0,mx]);axis('image'); colormap(gray); title(['re-aligend, SNR: ' num2str(-20*log10(norm(a-Amm(:,:,alnID))/norm(a(:))))]);
% subplot(2,2,3); imagesc(abs(R),[0,mx]);axis('image'); colormap(gray); title('ref');
% % subplot(2,3,5); imagesc(abs(Am),[0,mx]);axis('image'); colormap(gray); title('aligned (Sie)');
% subplot(2,2,4); imagesc(abs(Am(:,:,alnID)),[0,mx]);axis('image'); colormap(gray); title('aligned (RA)');