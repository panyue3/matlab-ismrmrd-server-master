
function ang_vel = find_angular_velocity(fname,k0)

a = readin_160_120_file(fname);
a1 = reshape_128_128_112103(a);
a_size = size(a1);

afft(1:128,1:128) = abs(fftshift(fft2(a1(:,:,1)))) ;    
a = xy2rt(afft(:,:,1),65,65,1:50,0:pi/180:2*pi-0.001) ;
e1 = sum(a(:,k0-2:k0+2),2);          e1 = e1 - mean(e1(:)) ; 

for i=1:a_size(3)
    afft(1:128,1:128) = abs(fftshift(fft2(a1(:,:,i)))) ;
    a = xy2rt(afft(:,:),65,65,1:50,0:pi/180:2*pi-0.001) ;
    e(1:360,i) = sum(a(:,k0-2:k0+2),2);          e = e - mean(e(:)) ; 
end

for n = 100
    j = 0;
    for i=1:3:a_size(3)-n
        j = j+1;
        c = my_xcorr(e(:,i+n),e(:,i));
        p = find(c ==max(c(:)));
        pt(j) = p(1);        p = 0;
    end
    % hist(pt,180),pause
    pt = mod(pt,60);    pt(find(pt>=30))=pt(find(pt>=30))-61;
    pt(find(pt==0)) = -1;
    if median(abs(pt(:))) >5.0, break , end
end

pt=0;n=n,
for i=1:a_size(3)-n
    pt(i) = peak1d(my_xcorr(e(:,i+n),e(:,i)));
end
pt = mod(pt,60);    
pt(find(pt>=30))= pt(find(pt>=30))-61;
pt(find(pt==0)) = -1;
ang_vel = abs(pt)/n;
    


