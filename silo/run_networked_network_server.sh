#!/bin/bash
# ops-per-worker is set to a very large value, so that TBENCH_MAXREQS controls how
# many ops are performed

if [ "$#" -ne 3 ]; then
    echo "Usage: ./run_networked.sh N_CLIENTS TBENCH_CLIENT_THREADS CLIENT_QPS."
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

NUM_WAREHOUSES=1
NUM_THREADS=1

PORT=9868

N_CLIENTS=$1
TBENCH_CLIENT_THREADS=$2
QPS=$3

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))


ssh -p 3322 jofepre@xpl2.gap.upv.es "rm -r ./client_*; rm -r ./lats*"
sudo rm -rf ./client_*
sudo rm -rf ./lats_*


echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} WARMUPREQS: ${WARMUPREQS} MAXREQS: ${MAXREQS}

# LAUNCH THE SERVER
TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} taskset -c 5,29 ${DIR}/out-perf.masstree/benchmarks/dbtest_server_networked --verbose --bench tpcc --num-threads ${NUM_THREADS} --scale-factor ${NUM_WAREHOUSES} --retry-aborted-transactions --ops-per-worker 10000000 &

echo $! > server.pid

sleep 5 # Allow server to come up

echo "Server ready. Clients can start now"

# Start the CLIENTS through SSH
ssh -p 3322 jofepre@xpl2.gap.upv.es "tailbench/silo/run_networked_network_client.sh ${N_CLIENTS} ${TBENCH_CLIENT_THREADS} ${QPS}"


wait $(cat server.pid)


kill -9 $(cat server.pid) > /dev/null 2>&1
rm server.pid


# Copy the lats.bin files from the client
for ((i=0; i<${N_CLIENTS}; i++)); do
    scp -P 3322 jofepre@xpl2.gap.upv.es:lats_${i}.bin ./
    scp -P 3322 jofepre@xpl2.gap.upv.es:client_${i}.sal ./
done


../utilities/agg-lats.sh
