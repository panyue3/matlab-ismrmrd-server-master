% Fit a 1_d array, use the adjacent 2 points on each side, find the value at the peak;
% reture the peak value and the position of the peak

function [peakval,peak] = findpeakval(a);

s = size(a);  
N = max(s(:));
N_max = find(a==max(a(:)));
if N >1;
	if (N_max(1) >= 3 & N_max(1) <= N/2 ) | (N-N_max(1) >= 3 & N_max(1) >=N/2 );
		a0(1:5) = a(N_max(1)-2:N_max(1)+2) ;
		pa = polyfit( N_max(1)-2:N_max(1)+2, a0, 2);
		dif_0 = 2*pa(1)*(1)+pa(2);
		dif_1 = 2*pa(1)*(N)+pa(2);

		if dif_0>0 & dif_1<0
			peakval = (polyval(pa,-pa(2)/pa(1)/2 )) ; %c=1,
			peak = -pa(2)/pa(1)/2 ;
		else
			peakval = max(a(:)) ;%c=2,
			peak = N_max(1) ;
		end 
	else 
		peakval = max(a(:)) ;
		peak = N_max(1) ;
        end
elseif N==1
	peakval = a ;%c=3,
	peak = N_max ;
else
        peakval = 0 ;%c=4,
	peak = 0 ;
end
