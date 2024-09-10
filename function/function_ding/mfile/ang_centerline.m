% Find the angle of the center line point, the centerline point are
% genreated by the PWVMeasure software. Since some of the centerline points
% are rejected in the PWV measurements, we only take the points that used
% in the centerline point in the output.

function cos_ang = ang_centerline(wave_dist, all_distances, ordered_i, ordered_j, imageSize)

% find all the points used in the PWV measurements
for i=1:length(wave_dist)
    temp = find(abs(all_distances - wave_dist(i)*10)< 0.000001);
    k(i) = temp(1); % index of the data points used in the PWV calculation
end

x = ordered_j;
y = ordered_i;

% find the angle for each data point
for i=1:length(x)
    L_t = max(1,i-10):min(length(x),i+10);
    x_t = x(L_t);
    y_t = y(L_t);
    % Try to get rid of the ill-conditioned case by choosing
    % polyfit(x_t,y_t,3) or polyfit(y_t,x_t,3)
    if (max(x_t) -min(x_t)) > (max(y_t) -min(y_t))
        %'a'
        p = polyfit(x_t,y_t,3); % 3rd order fit y = ax^3 + bx^2 + cx + d
        tan_t(i) = 3*p(1)*(x(i)^2) + 2*p(2)*x(i) + p(3) ; % this is the slope y' = 3ax^2 + 2bx + c
        cos_t(i) = sqrt( 1/( 1/tan_t(i)^2 + 1 ) );
    else
        %'b'
        p = polyfit(y_t,x_t,3); % 3rd order fit y = ax^3 + bx^2 + cx + d
        tan_t(i) = 3*p(1)*(y(i)^2) + 2*p(2)*y(i) + p(3) ; % this is the slope y' = 3ax^2 + 2bx + c
        cos_t(i) = sqrt( 1/( tan_t(i)^2 + 1 ) );
    end
end

cos_ang = cos_t(k);





