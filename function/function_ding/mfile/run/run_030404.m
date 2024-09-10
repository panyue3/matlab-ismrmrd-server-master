% Run_030404
% Try to define the chiral asymmetry of vorticity of the pattern by
% calculate angular momemtum.
[x,y] = meshgrid(1:128,1:128);
%fid = fopen('1456_3381_90_0_32','r');a=0; for i=1:3500, a(1:160,1:120)=fread(fid,[160,120],'uchar');end, 'finish skip'
%for i=1:200,  a(1:160,1:120,i)=fread(fid,[160,120],'uchar');end, fclose(fid);'finish readin'
%a0 = reshape_128_128_112103(a,'bicubic'); a=0;'finish reshape'
%asize = size(a0);
for i = 1:asize(3)
    a0(:,:,i) = a0(:,:,i) -min(min( a0(:,:,i) ))+1;
    [px,py] = gradient(a0(:,:,i));
    
    %imagesc(x.*py-y.*px)
    j(i)=sum(sum( (x.*py-y.*px)./a0(:,:,i) ));
end
plot(j)
