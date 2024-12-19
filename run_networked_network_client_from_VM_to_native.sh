#!/bin/bash
# ops-per-worker is set to a very large value, so that TBENCH_MAXREQS controls how
# many ops are performed

if [ "$#" -ne 4 ]; then
    echo "Usage: ./run_networked.sh BENCHMARK N_CLIENTS TBENCH_CLIENT_THREADS CLIENT_QPS."
    exit 0
fi


BENCH=${1}
N_CLIENTS=$2
TBENCH_CLIENT_THREADS=$3
QPS=$4

NUM_THREADS=1
PORT=9868
SERVER_IP=192.168.10.4

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))


cd ${BENCH}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

#echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} 


# The system has 12 SMT cores (the first five reserved for the os and dpdk)
for ((i=0; i<${N_CLIENTS}; i++)); do

    c1=2
    c2=3
    cpu_set=${c1},${c2}

    if [ "${BENCH}" = "img-dnn" ]; then    
        # LAUNCH A CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} TBENCH_MNIST_DIR=${DATA_ROOT}/img-dnn/mnist taskset -c ${cpu_set} ${DIR}/img-dnn_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid

    elif [ "${BENCH}" = "silo" ]; then    
        # LAUNCH A CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_ID=${i} taskset -c ${cpu_set} /home/jofepre/tailbench/silo/out-perf.masstree/benchmarks/dbtest_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid
    fi

    # Update the cpu_set
    c1=$(echo "$c1+1" | bc -l)
    c2=$(echo "$c2+1" | bc -l)
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

exit 0

