function y = funfit_1_3(a,x)
y = tanh(x*.005).*(a(1)*x.^3 + a(2)*x);
