#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: ./run_networked.sh N_CLIENTS TBENCH_CLIENT_THREADS CLIENT_QPS."
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh
#cd ${DIR}

# Run specjbb
TBENCH_PATH=../harness

PORT=9868
SERVER_IP=192.168.10.4

N_CLIENTS=${1}
TBENCH_CLIENT_THREADS=${2}
QPS=${3}

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))


echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} 

export LD_LIBRARY_PATH=${TBENCH_PATH}:${LD_LIBRARY_PATH}

export CLASSPATH=./build/dist/jbb.jar:./build/dist/check.jar:${TBENCH_PATH}/tbench.jar

export PATH=${JDK_PATH}/bin:${PATH}

export TBENCH_QPS=${QPS}
export TBENCH_MAXREQS=${MAXREQS}              #25000 
export TBENCH_WARMUPREQS=${WARMUPREQS}        #25000 
export TBENCH_MINSLEEPNS=100

export TBENCH_NCLIENTS=${N_CLIENTS}
export TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS}

export TBENCH_SERVER=${SERVER_IP}
export TBENCH_SERVER_PORT=${PORT}

if [[ -d libtbench_jni.so ]] 
then
    rm libtbench_jni.so
fi
ln -sf libtbench_networked_jni.so libtbench_jni.so


# XPL2 has 12 SMT cores (the first five reserved for the OS and DPDK)
c1=5
c2=17
cpu_set=${c1},${c2}


for ((i=0; i<${N_CLIENTS}; i++)); do

    # LAUNCH A CLIENT
    export TBENCH_ID=${i}
    taskset -c ${cpu_set} ${DIR}/client 2>&1 | tee client_${i}.sal &
    
    echo $! > client_${i}.pid

    #Update te cpu set
    c1=$(echo "$c1+1" | bc -l)
    c2=$(echo "$c2+1" | bc -l)
    if [ $c1 -eq 12 ]; then      
        c1=5
        c2=17
    fi
    cpu_set=${c1},${c2}
done


# Wait all of them
for ((i=0; i<${N_CLIENTS}; i++)); do
    wait $(cat client_${i}.pid)
done


# Clean up
for ((i=0; i<${N_CLIENTS}; i++)); do
    kill -9 $(cat client_${i}.pid) > /dev/null 2>&1
    rm client_${i}.pid
done


# Teardown
rm libtbench_jni.so

