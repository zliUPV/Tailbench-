#!/bin/bash

# moses needs gcc/g++ v5

sudo ln -sf /usr/bin/g++-5 /usr/bin/g++
sudo ln -sf /usr/bin/gcc-5 /usr/bin/gcc

export TBENCH_PATH=${PWD}/../harness
export CPATH=${TBENCH_PATH}${CPATH:+:$CPATH}
./bjam toolset=gcc -j32 -q

#if [ "$(hostname)" != "CIHR" ] && [ "$(hostname)" != "XPL4" ] && [ "$(hostname)" != "XPL2" ]; then
#    sudo chown huawei moses.ini
#    sudo chgrp huawei moses.ini
#fi

sudo ln -sf /usr/bin/g++-7 /usr/bin/g++
sudo ln -sf /usr/bin/gcc-7 /usr/bin/gcc
