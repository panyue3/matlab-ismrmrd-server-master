% This is the function to fit a function with 2-D Gaussian function.
% Fit_2D_Gaussian(a) this is to get the best Gaussian fit of a
% autocorrelation function with peak at the center of the image.


%function diff = Fit_2D_Gaussian(a, x_c, y_c, sigma)

function d = Fit_2D_Gaussian(a)

s = size(a);
[x, y] = meshgrid(1:s(2),1:s(1));

n = [0.01:0.01:1, 1.1:0.1:2, 2.2:0.2:4, 5:100];
for i=1:length(n)
    g = exp(-((x - round(s(2)/2+0.5)).^2 +(y - round(s(1)/2+0.5)).^2)/(2*n(i)));
    %g = g / sum(g(:));
    %g = (g - mean(g(:)))/std(g(:));
    %imagesc(g), title(num2str((n(i)))), pause
    c(i) = sum(sum( (g - mean(g(:))).*(a-mean(a(:))) ))/std(g(:));
end
plot(n,c,'*') 
%%p = polyfit(n,c,2); % y = a*x^2 + b*x + c

%d = -p(2)/2/p(1);   % x = -b/(2*a)

n_0 = find(c ==max(c(:)));
d = (n(n_0(1)));








