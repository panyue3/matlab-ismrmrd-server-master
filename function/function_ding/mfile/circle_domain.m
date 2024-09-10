% solve the problem the the the angle may be smaller than 0 or
% larger than 360. If the new peak is within +/- 30 degree of the
% old peak, it will be found.

function peak_1 = circle_domain(theta,ang)

        if ang < theta+1;       peak_1 = [mod(ang-theta-1,360)+1:360 1:ang + theta]; 
        elseif ang > 360-theta, peak_1 = [ang-theta-1:360 1:mod(ang+theta,360)];
        else                    peak_1 = [ang-theta:ang+theta];
        end
        return

