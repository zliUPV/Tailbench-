#!/bin/bash

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

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))

echo RESULT ${BENCH} N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} WARMUPREQS: ${WARMUPREQS} MAXREQS: ${MAXREQS}

cd ${BENCH}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh


if [ "${BENCH}" = "img-dnn" ]; then
    
    REQS=100000000    # Set this very high; the harness controls maxreqs

    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} taskset -c 5,29 ${DIR}/img-dnn_server_networked -r ${NUM_THREADS} -f ${DATA_ROOT}/img-dnn/models/model.xml -n ${REQS} &
    echo $! > server.pid

elif [ "${BENCH}" = "silo" ]; then

    NUM_WAREHOUSES=1

    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} taskset -c 5,29 ${DIR}/out-perf.masstree/benchmarks/dbtest_server_networked --verbose --bench tpcc --num-threads ${NUM_THREADS} --scale-factor ${NUM_WAREHOUSES} --retry-aborted-transactions --ops-per-worker 10000000 &
    echo $! > server.pid

fi




sleep 5 # Allow server to come up

echo "Server ready. Clients can start now"


# Start the CLIENT through SSH
ssh huawei@192.168.10.201 "tailbench-repo/tailbench/run_networked_network_client_from_VM_to_native.sh ${BENCH} ${N_CLIENTS} ${TBENCH_CLIENT_THREADS} ${QPS}"


wait $(cat server.pid)


kill -9 $(cat server.pid) > /dev/null 2>&1
rm server.pid


# Copy the lats.bin files from the client
for ((i=0; i<${N_CLIENTS}; i++)); do
    scp huawei@192.168.10.201:lats_${i}.bin ./
    scp huawei@192.168.10.201:client_${i}.sal ./
done
ssh huawei@192.168.10.201 "rm -r ./client_*; rm -r ./lats*"


../utilities/agg-lats.sh
