function hw6132()

c0=[1.5;2.0;0;0;0;0];

options=optimset('DISPLAY','iter');

[c,fval,output]=fsolve(@rhc,c0,options);

c

end;

 

function f=rhc(c)

ca0=1.5;

cb0=2.0;

kd1=0.25;

ke2=0.1;

kf3=5.0;

tau=5;

f=[c(1)-ca0+(kd1*c(1)*c(2)^2+3*ke2*c(1)*c(4))*tau;

   c(2)-cb0+(2*kd1*c(1)*c(2)^2+kf3*c(2)*c(3)^2)*tau;

   (kd1*c(1)*c(2)^2+ke2*c(1)*c(4)-2*kf3*c(2)*c(3)^2)*tau-c(3);

   (kd1*c(1)*c(2)^2-2*ke2*c(1)*c(4)+kf3*c(2)*c(3)^2)*tau-c(4);

   tau*ke2*c(1)*c(4)-c(5);

   tau*kf3*c(2)*c(3)^2-c(6)];

end;

 

Output:

                                        Norm of      First-order   Trust-region

 Iteration  Func-count     f(x)          step         optimality    radius

     0          7          393.75                           409               1

     1         14         238.065       0.908914      1.04e+003               1

     2         21         17.7903       0.542085            138               1

     3         28        0.920322       0.257762           17.8            1.36

     4         35       0.0176808       0.0684091           1.81            1.36

     5         42    2.28128e-005        0.010665         0.0602            1.36

     6         49    5.14517e-011       0.000406871      9.02e-005            1.36

     7         56    2.79063e-022      6.12557e-007       2.1e-010            1.36

Optimization terminated successfully:

 First-order optimality is less than options.TolFun.

c =  0.6083

    0.7927

    0.1127

    0.4535

    0.1379

0.2516