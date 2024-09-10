addpath 012104_2
fid = fopen('1450_3367_90_0_32','r');a=0; % for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 
'Reading in files ...'
for i=1:100,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);
'finished readin, reshaping ...'
a0 = reshape_128_128_112103(a,'bicubic'); a=0;%imagesc(a0(:,:,1)), break
'reshape finished'
a = 0;b=0;
for i=1:100
    c =  Compare_Chirality(a0(:,:,i));i,pause(1),
    chiral(i) = min(c(:));
    %chirality_012104_1450_0_500(i) = Compare_Chirality(a0(:,:,i));i,pause(1)
    %a1=0;a=0;b=0;
    %a = imresize(a0(:,:,i),0.5,'bicubic');
    %a = (a>0.1*max(a(:))).*a/max(a(:)); clock ; chirality(i) = try_chiral_1(a),  i,pause(1);
    %a1 = a>0.1*max(a(:)); [x,y] = find(a1>0); a = (a1).*a/max(a(:)); N = length(x),  for j=1:N, b(j)=a(x(j),y(j));end;clock , i,chirality(i) = try_2(b,x,y),   pause(1);
end
% b=0;x=0;y=0;a1 = a>0.1*max(a(:)); [x,y] = find(a1>0); a = (a1).*a/max(a(:)); N = length(x),  for j=1:N, b(j)=a(x(j),y(j));end;clock , chiral = try_2(b,x,y), clock, pause(1);

clear a0;