% function M=showmoviepic(fname,number)
% show picture of a movie file 160*120, 
%each movie file has 40 pics, show the No. number pic 
function pic=showmoviepic(fname,number)
m=160;n=120;i=1;
fid = fopen(fname,'r');
a=fread(fid,[m,n],'uchar');
b=zeros(m,n,2);b(:,:,1)=a+1;
while prod(size(a))==m*n,
a=fread(fid,[m,n],'uchar');
if prod(size(a))==m*n,i=i+1;b(:,:,i)=a+1;end;
end
fclose(fid);
b1 = ones(128,128,i);  
b1(:,5:124,:)=b(19:146,:,:);

b1(:,:,number)=b1(:,:,number)./(lpfilter(b1(:,:,number),0.06)+0.1);
%for j=1:i
%   b1(:,:,j)=b1(:,:,j)./(lpfilter(b1(:,:,j),0.06)+0.1);
%  j=j
%   img(b1(10:110,10:110,j)),% pause(0.1)
%    M(j)=getframe;

%end
%    movie(M)
pic = ones(160,120);
pic = b1(:,:,number);

