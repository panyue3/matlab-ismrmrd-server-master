% fitimg use fit method to find the local k
% [a,k,thi,phi] = fitimg(c) c is the img. a is the amplitude,
% k is the wave vector, thi is the wave vector direction angle
%      phi is the phase

    function [af,kf,thif,phif] = fitimg(c)
    
    [l0,m0] = size(c);  k0 = roughk(c);
    len = floor(sqrt(l0*m0/k0/k0));
    in = 32; inc = 0.001; n1 = 0;
    edge =20;
for i1 =2*len+edge:in:l0-2*len-edge
    n1 = n1 + 1 ; n2 = 0;   
  for i2=2*len+edge:in:m0-2*len-edge
    n2 = n2 + 1 ; z=1;
%   z = hanning(2*len+1)*hanning(2*len+1)';
    b = c(i1-len:i1+len,i2-len:i2+len).*z;
    sf = l0/(2*len+1);
    
    [l1,m1]=size(b);
    [k0,thi] = wave4k(b,len+1,len+1);
    k0 = k0 * l0 /l1 ;
    b = embed(b,sf);
    len0 = floor(sqrt(l0*m0/k0/k0));
%    size(b), i1=i1,i2=i2
    b = c(i1-len0:i1+len0,i2-len0:i2+len0);
% Find the amplitude a , angle thi and phase phi 
    a = (max(b(:))-min(b(:)))/2;        
    [thi0,phi] = findang(b,1,k0);
% Find the best fit numerically
    p(1)=a;p(2)=k0;p(3)=thi;p(4)=phi;
        [p,fveal] = fminsearch('tarfun',p,[optimset('TolFun',1e-6)],b); 
        af(n1,n2)=p(1);kf(n1,n2)=p(2);thif(n1,n2)=p(3);phif(n1,n2)=p(4);
  end    
end     
    
%a=p(1);k=p(2);thi=p(3);phi=p(4);
