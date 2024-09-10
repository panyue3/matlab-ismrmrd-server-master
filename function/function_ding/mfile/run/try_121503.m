 fid=fopen('1456_3381_90_0_32','r'),j=1;
 for i=1:3000, 
     i,
     a0=fread(fid,[160,120],'uchar'); 
     afft =abs(fft2(a0)); 
     median_afft=median(afft(:)), 
     pause(0.01),
     clear a0, clear afft,  
 end;
 
     a0=fread(fid,[160,120],'uchar'); 
     afft =abs(fft2(a0)); 
     median_afft=median(afft(:)), 
     imagesc(a0)
     fclose(fid)