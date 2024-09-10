% Another try of 2-D Gaussian fit

%function [d_y,d_x] = try_Gaussian_2D(a)
function d = try_Gaussian_2D(p, a )

s = size(a);
[x,y] = meshgrid(1:s(2),1:s(1));
x_c = round((s(2)+1)/2);
y_c = round((s(1)+1)/2);
b = p(3)*exp(-(x - x_c).^2/p(1)^2 -(y - y_c).^2/p(2)^2 );

d = b - a;












%%% The i-D fitting does not work
% s = size(a);
% x = sum(a,1);
% y = sum(a,2)';
% 
% x_c = find(x==max(x));
% y_c = find(y==max(y));
% 
% diff_x = diff(x);
% diff_y = diff(y);
% 
% for i=x_c:round(s(2)-1),
%     %i,
%     if (diff_x(i) >0)|(x(i+1)<0), w_x = i-x_c; break, end
% end
% 
% for i=y_c:round(s(1)-1), 
%     if (diff_y(i) >0)|(y(i+1)<0), w_y = i-y_c; break, end
% end
% 
% x0 = [x_c-w_x:x_c+w_x]; % x-coordinate
% y0 = [y_c-w_y:y_c+w_y];
% xI = x(x0); % Cut the center out
% yI = y(y0);
% 
% p_x = polyfit(x0, log(xI),2);
% p_y = polyfit(y0, log(yI),2);
% 
% d = sqrt(-1/(p_x(1)+p_y(1)));


% figure(1), plot(x0, xI, '*', x0, exp(polyval(p_x, x0)))
% figure(2), plot(y0, yI, '*', y0, exp(polyval(p_y, y0)))
% 
% sqrt(-0.5/p_x(1))
% sqrt(-0.5/p_y(1))
% 
% std(xI)
% std(yI)





 options = optimset('LargeScale','off','TolFun',0.00000001, 'Tolx',0.00000001);
% 
% p_x = [ w_x, std(xI),xI(w_x+1)  ],
% p_x_f = fminunc(@fitGaussian1D,p_x,options,xI,[x_c-w_x:x_c+w_x]),
% 
% p_y = [ w_y, std(yI),yI(w_y+1) ],
% p_y_f = lsqnonlin(@fitGaussian1D,double(p_y),[],[],options,double(yI),double([y_c-w_y:y_c+w_y])),

% dy = p_y_f(2);
% dx = p_x_f(2);


%[x_c-w_x:x_c+w_x; x(x_c-w_x:x_c+w_x)]







%     options = optimset('Largescale','off');
% 
%     % initial approximation T1
%  
%     T1 = Time(Min_order)/0.693;
%     
%     X0=[T1 X0];
%     
%     %calculate the new coefficients sing LSQNONLIN
%     x=lsqnonlin(@fit_simpT1, X0, [],[],options,Time,Intensity_corrected);
