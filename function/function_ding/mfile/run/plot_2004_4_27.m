%x = 2.238:0.001:2.276;
%y = [median(c2238),median(c2239),median(c2240),median(c2241),median(c2242),median(c2243),median(c2244),median(c2245),
%    median(c2246),median(c2247),median(c2248),median(c2246),median(c2246),
%    median(c2246),median(c2246),median(c2246),];%

%plot(x,abs(y),'*-')
p = zeros(10,301,39);
p(:,:,1) = p2238; p(:,:,2) = p2239; p(:,:,3) = p2240; p(:,:,4) = p2241; p(:,:,5) = p2242; p(:,:,6) = p2243; p(:,:,7) = p2244;
p(:,:,8) = p2245; p(:,:,9) = p2246; p(:,:,10) = p2247; p(:,:,11) = p2248; p(:,:,12) = p2249; p(:,:,13) = p2250; p(:,:,14) = p2251;
p(:,:,15) = p2252; p(:,:,16) = p2253; p(:,:,17) = p2254; p(:,:,18) = p2255; p(:,:,19) = p2256; p(:,:,20) = p2257; p(:,:,21) = p2258;
p(:,:,22) = p2259; p(:,:,23) = p2260; p(:,:,24) = p2261; p(:,:,25) = p2262; p(:,:,26) = p2263; p(:,:,27) = p2264; p(:,:,28) = p2265;
p(:,:,29) = p2266; p(:,:,30) = p2267; p(:,:,31) = p2268; p(:,:,32) = p2269; p(:,:,33) = p2270; p(:,:,34) = p2271; p(:,:,35) = p2272;
p(:,:,36) = p2273; p(:,:,37) = p2274; p(:,:,38) = p2275; p(:,:,39) = p2276; 
for n = 1:39;
app=zeros(10,301); ann = zeros(10,301);
for i=1:10;a = p(i,:,n);ad=my_diff(a,4);ad=abs(ad); ap=ad(find(ad>0));end
app=ap(find(ap>0));
r(1:3,n)=[median(app(:)) mean(app(:)) std(app(:))]'; ap=0;an=0;
end

x = (2.238:0.001:2.276)';
y = r(:,1:39);

plot(x,y(1,:),'d-'), hold on
errorbar(x,y(1,:),y(3,:))
xlabel('Acceleration(g)','fontsize',14)
ylabel('Rotaion Speed(degree per 5 sec)','fontsize',14)
title('Rotaion Speed vs Driving','fontsize',14)



