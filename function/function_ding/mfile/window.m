% apply a circular window window(a,r,x,y) 
% a is the image , r is radius of wndow, x,y window center. 

function a0 = window(a,r,x,y);

a = double(a) ; z = 0 ; c = 0 ; c0 = 0 ; b = 0 ; a1 = 0 ; b1 = 0 ;

[sx,sy] = size(a);

[x1,y1] = meshgrid((-sx/2+0.5):(sx/2-0.5),(-sy/2+0.5):(sy/2-0.5));

z = ((r*r -(x1.^2 + y1.^2))/(r*r) ) ;
c = ( z >= 0 ) ;
c0 = c.*z ;
b = a.*c ;

immean = sum(b(:))/( length( find(b(:)>0) ) );
b1 = ones(size(a)) * immean ;
a1 = b - b1.*c ;
a0 = a1.*c0 ;
figure(2)
img(z)
figure(3)
img(c)
