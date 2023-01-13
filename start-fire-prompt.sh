#!/bin/sh

if [ $# -eq 1 ]; then
    LOG_FILE=${1}
    docker run --rm -p 9095:9095 fire-matlab-server 9095 LOG_FILE
else
    docker run --rm -p 9095:9095 fire-matlab-server 9095
fi