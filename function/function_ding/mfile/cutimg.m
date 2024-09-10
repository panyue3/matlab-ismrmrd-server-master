% [anew, lenperpix,decifac,r] = cutingimg(a) 'a' is the image, 'anew' is
% the image after the embeding , 'lenperpix' is the length per pixel of
% the picture, 'decifac' is the deci factor.'r' diameter of the cell. 
% x,y,r is the output from findcen.m

function [anew, lenperpix, decifac,r] = cutimg(a,x,y,r);

'cuting image, wait ...'
a = double(a);
a = lpfilter(a,0.618,0.628);
[sy,sx] = size(a);
sy0 = (sy + 1) / 2 ;
sx0 = (sx + 1) / 2 ;
%[x,y,r] = findcen(a);
lenperpix =( 1 + 0.06)* 71 / r ;
r=r-22;
sy1 = sy0 + y; 
sx1 = sx0 + x; 

s1 = sy0 - abs(y); 
if r < sy0 + 1 ,
     s1 = r;
end
r = r-0.5 ;

[y1,x1] = meshgrid((-sx/2-x + 0.5):(sx/2-0.5-x),(-sy/2-y+0.5):(sy/2-0.5-y));
z = sqrt( x1.^2 + y1.^2 );
c1 = ( z <  r);

b = a.*c1 ;
meanmat=sum(b(:))/length(find(b(:)>0));
b=ones(size(a))*meanmat;
b=b.*(1-c1);
b=b+a.*c1;

s = round( 2 * s1 - 0.9 ) - 3  ;
if 2 * round( s / 2 - 0.1 ) == s,
   s = s - 1 ;
end

d = s;
anew1=b((sy1-(s-1)/2):(sy1+(s-1)/2),(sx1-(s-1)/2):(sx1+(s-1)/2));

pp = find(anew1);
mn = mean(anew1(pp));
c0 = (anew1 == meanmat);
c2 = c0 * mn ;
anew1 = anew1.*(1-c0) + c2 ;
anew0 = lpfilter(anew1, 0.03,0.032) ;
anew =anew1./anew0;
sz = size(anew);

% get ride of the edges
anew = anew.*(1-c0) ;
mn0 = sum(anew(:))/length(find(anew)); 
anew = anew - mn0*(1-c0);
%figure(2)
%img(anew)
%anewmean = mean(anew(:))

decifac = sz(1)/256;
b=deci(anew,decifac);
anew=b;
lenperpix = lenperpix * decifac;
r = r / decifac;
'finish cutting image'
