% function w = tukey_radial(r, r_c, r_t)
% tukey window in the radial direction
% r_c: ratio of center flat region, r_c <1, 
% r_t: ratio of transition region, r_c<r_t<1,
% Region (1-r_t)*r_max: 0,
% Yu Ding 2017-05-25

function w = tukey_radial(r, r_c, r_t)

w = zeros(size(r));
if r_t <= r_c, disp('r_t MUST > r_c !'), return, end
if r_t > 1, disp('r_t MUST < 1 !'), return, end
    
r_max = max(abs( r(:) ));
r_c = r_max*r_c;
r_t = r_max*r_t;

for i=1:length(r(:))
    if r(i) <= r_c
        w(i) = 1;
    elseif ((r(i) > r_c) && (r(i) <= r_t))
        w(i) = (1+cos( pi*(r(i)-r_c)/(r_t-r_c) ))/2;
    end
end



