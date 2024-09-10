function k0 = checkmoviek(i1)
k = 0 ; a = 0 ; b0 = 0; stepshift = 11.4 ;
%for i = 2700
% for i = 2510-round(stepshift*(i1-110)/100)*10:10:2750-round(stepshift*(i1-110)/10)
for i = 4100:100:4100   
for j = i1
    k=k+1;a=0;b=0;
    b1 = zeros(256,256);
    fname = sprintf('%i_%i_%i_%imov',0,0,i,j);
    fid=fopen(fname); a=0;
    a=fread(fid,[160,120],'uchar');
    fclose(fid);
    b(1:64,1:64)=a(34:97,29:92)+1;
    if k == 1,
        b0 = lpfilter(b,0.0618)+1;
    end
    b = b./b0;   figure(1), imagesc(b./b0), colorbar
    b=lpfilter(b,0.618); b=lpfilter(b,0.618);
    b=hpfilter(b,0.03);
    b=b-mean(b(:));
    b1(129-31:129+32,129-31:129+32) = b;
    c = abs(fftshift(fft2(b1))) ; 
    %d = xy2rt(c,129,129,1:50,0:0.1:2*pi);
    d = xy2rt(c,129,129,1:100,0:0.1:2*pi);
    %e = sum(d,1).*(1:50); plot(e)
    e = sum(d,1).*(1:100); plot(e)
    k0(k) = peak1d(e);
    % pause(5)
end, end
    k0 