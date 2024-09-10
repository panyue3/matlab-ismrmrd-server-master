x=(2.230:0.005:2.345)';
y = [r2230;
    r2235;
    r2240;
    r2245;
    r2250;
    r2255;
    r2260;
    r2265;
    r2270;
    r2275;
    r2280;
    r2285;
    r2290;
    r2295;
    r2300;
    r2305;
    r2310;
    r2315;
    r2320;
    r2325;
    r2330;
    r2335;
    r2340;
    r2345;
];

plot(x,y(:,1),'d-'), hold on
errorbar(x,y(:,1),y(:,3))
x1 = 2.240:0.001:2.245;
y1 = [r2240_new;
    r2241;
    r2242;
    r2243;
    r2244;
    r2245_new;
];
plot(x1,y1(:,1),'d-'), 
errorbar(x1,y1(:,1),y1(:,3))
xlabel('Acceleration(g)','fontsize',14)
ylabel('Rotaion Speed(degree per 5 sec)','fontsize',14)
title('Rotaion Speed vs Driving','fontsize',14)
