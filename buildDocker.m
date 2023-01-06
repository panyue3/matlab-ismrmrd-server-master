addpath('mex');
addpath(genpath('function'))
res = compiler.build.standaloneApplication('fire_matlab_ismrmrd_server.m', 'TreatInputsAsNumeric', 'on');
opts = compiler.package.DockerOptions(res, 'ImageName', 'fire-matlab-server');
compiler.package.docker(res, 'Options', opts)