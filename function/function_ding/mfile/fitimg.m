% fitimg use fit method to find the local k
% [a,k,thi,phi] = fitimg(c) c is the img. a is the amplitude,
% k is the wave vector, thi is the wave vector direction angle
%      phi is the phase

    function [af,kf,thif,phif] = fitimg(c)
    
    [l0,m0] = size(c);  k0 = roughk(c);
    len = floor(sqrt(l0*m0/k0/k0));
    in = 64; inc = 0.001; n1 = 0;

for i1 =2*len:in:l0-2*len
    n1 = n1 + 1 ; n2 = 0;   
  for i2=2*len:in:m0-2*len
    n2 = n2 + 1 ;
    z = hanning(2*len+1)*hanning(2*len+1)';
    b = c(i1-len:i1+len,i2-len:i2+len).*z;
    sf = l0/(2*len+1);
    b = embed(b,sf);
    size(b);
    k0 = roughk(b);
    k0 = 21;
    len0 = floor(sqrt(l0*m0/k0/k0));
    b = c(i1-len0:i1+len0,i2-len0:i2+len0);
% Find the amplitude a , angle thi and phase phi 
    a = (max(b(:))-min(b(:)))/2;        
    [thi,phi] = findang(b,1,k0);
% Find the best fit numerically
    p(1)=a;p(2)=k0;p(3)=thi;p(4)=phi;
    for i0=1:10000
        m(1) = tarfun(b,p(1)-inc,p(2),p(3),p(4));    
        m(2) = tarfun(b,p(1)+inc,p(2),p(3),p(4));
        m(3) = tarfun(b,p(1),p(2)-inc,p(3),p(4));
        m(4) = tarfun(b,p(1),p(2)+inc,p(3),p(4));
        m(5) = tarfun(b,p(1),p(2),p(3)-inc,p(4));
        m(6) = tarfun(b,p(1),p(2),p(3)+inc,p(4));
        m(7) = tarfun(b,p(1),p(2),p(3),p(4)-inc);
        m(8) = tarfun(b,p(1),p(2),p(3),p(4)+inc);
        z = find(m == min(m));
        if abs(min(m)-tarfun(b,p(1),p(2),p(3),p(4)))<0.00001, 
          'break'
        break;end
 p(floor((z+1)/2)) =p(floor((z+1)/2))+inc*(-1)^(z-2*floor(z/2));
    end 
        af(n1,n2)=p(1);kf(n1,n2)=p(2);thif(n1,n2)=p(3);phif(n1,n2)=p(4);
  end    
end     
    
%a=p(1);k=p(2);thi=p(3);phi=p(4);
