



function max_val = find_max_average_ang(peak)

    a0 = peak1d(peak);
    a0 = round(a0);
    a1 = mod(a0-1:10:a0+35,40);     a2 = mod(a0:10:a0+35,40);       a3 = mod(a0+1:10:a0+35,40);
    data(1:4) = peak(a1);           data(5:8) = peak(a2);           data(9:12) = peak(a3);
    peak(a1) = median(peak(:));    peak(a2)=peak(a1);              peak(a3) = peak(a1);
    
    a0 = peak1d(peak);
    a0 = round(a0);
    a1 = mod(a0-1:10:a0+35,40);     a2 = mod(a0:10:a0+35,40);       a3 = mod(a0+1:10:a0+35,40);
    data(13:16) = peak(a1);   data(17:20) = peak(a2);   data(21:24) = peak(a3);
    
    data = sort(data);
    max_val = median(data(21:24));