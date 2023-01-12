#!/bin/sh

if [ $# -eq 1 ]; then
    LOG_FILE=${1}
    matlab -nodesktop -nosplash -r "cd /opt/code/fire-matlab-ismrmrd-server/;fire_matlab_ismrmrd_server(9095,'${LOG_FILE}')"
else
    matlab -nodesktop -nosplash -r "cd /opt/code/fire-matlab-ismrmrd-server/;fire_matlab_ismrmrd_server(9095)"
fi