close all hidden
%rmpath 2400Hz
rmpath 021104/2320Hz
addpath 021104/2330Hz

i = 1465;   j=round(i*2.322);

fname=sprintf('%d_%d_90_0_210',i,j),

%[p2330(1:501),s2330(1:2),kr2330, delta_kr2330, delta_theta2330] = find_mov_peak_ang_peaksize(fname,12);

plot(p2330)
