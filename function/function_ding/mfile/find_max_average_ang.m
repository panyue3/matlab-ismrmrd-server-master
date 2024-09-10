% Find the peak of the qp or other measure and then find 90 degree away
% from it, then find the first largest 4 and make average. The image or 
% data points should be 9 degree apat from each other. And I assume that
% there is an period of 90 degrees.  
% function max_val = find_max_averag(peak)

function max_val = find_max_average_ang(peak)
    % plot(peak) 
    a0 = peak1d(peak);
    a0 = round(a0);
    a1 = mod(a0-1:10:a0+35,40);     a2 = mod(a0:10:a0+35,40);       a3 = mod(a0+1:10:a0+35,40);
    b = [a1 a2 a3];                 b(find(b == 0)) = 40;
    data(1:12) = peak(b);           
    peak(b) = median(peak(:));    
    
    a0 = peak1d(peak);
    a0 = round(a0);
    a1 = mod(a0-1:10:a0+35,40);     a2 = mod(a0:10:a0+35,40);       a3 = mod(a0+1:10:a0+35,40);
    b = [a1 a2 a3];                 b(find(b == 0)) = 40;
    data(13:24) = peak(b);  
    
    data = sort(data);
    max_val = median(data(20:24));