#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: ./run_networked.sh BENCHMARK N_CLIENTS TBENCH_CLIENT_THREADS CLIENT_QPS."
    exit 0
fi

USER=jofepre

BENCH=$1
N_CLIENTS=$2
TBENCH_CLIENT_THREADS=$3
QPS=$4

NUM_THREADS=1
PORT=9868

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))

sudo runuser -l huawei -c "ssh -p 3322 ${USER}@xpl2.gap.upv.es \"rm -r ./client_*; rm -r ./lats*\"" &> /dev/null
sudo rm -rf ./client_* &> /dev/null
sudo rm -rf ./lats_* &> /dev/null

cd ${BENCH}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

echo RESULT ${BENCH} N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} WARMUPREQS: ${WARMUPREQS} MAXREQS: ${MAXREQS}


if [ "${BENCH}" = "img-dnn" ]; then
    
    REQS=100000000    # Set this very high; the harness controls maxreqs

    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} ${DIR}/img-dnn_server_networked -r ${NUM_THREADS} -f ${DATA_ROOT}/img-dnn/models/model.xml -n ${REQS} &
    echo $! > server.pid


elif [ "${BENCH}" = "silo" ]; then

    NUM_WAREHOUSES=1

    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} ${DIR}/out-perf.masstree/benchmarks/dbtest_server_networked --verbose --bench tpcc --num-threads ${NUM_THREADS} --scale-factor ${NUM_WAREHOUSES} --retry-aborted-transactions --ops-per-worker 10000000 &
    echo $! > server.pid


elif [ "${BENCH}" = "masstree" ]; then

    NUM_WAREHOUSES=1
    
    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} ${DIR}/mttest_server_networked -j${NUM_THREADS} mycsba masstree &
    echo $! > server.pid

elif [ "${BENCH}" = "shore" ]; then

    DUMMYREQS=1000000 # set this really high so MAXREQS controls execution

    # Setup
    rm -f log scratch cmdfile db-tpcc-1 diskrw shore.conf info server.pid client.pid

    TMP=$(mktemp -d --tmpdir=${SCRATCH_DIR})
    ln -s $TMP scratch

    mkdir scratch/log && ln -s scratch/log log
    mkdir scratch/diskrw && ln -s scratch/diskrw diskrw

    cp ${DATA_ROOT}/shore/db-tpcc-1 scratch/ && ln -s scratch/db-tpcc-1 db-tpcc-1
    chmod 644 scratch/db-tpcc-1

    cp shore-kits/run-templates/cmdfile.template cmdfile
    sed -i -e "s#@NTHREADS#$NUM_THREADS#g" cmdfile
    sed -i -e "s#@REQS#$DUMMYREQS#g" cmdfile

    cp shore-kits/run-templates/shore.conf.template shore.conf
    sed -i -e "s#@NTHREADS#$NUM_THREADS#g" shore.conf
    
    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} ${DIR}/shore-kits/shore_kits_server_networked -i cmdfile &
    echo $! > server.pid


elif [ "${BENCH}" = "moses" ]; then

    # Setup
    cp ${DIR}/moses.ini.template ${DIR}/moses.ini
    sed -i -e "s#@DATA_ROOT#$DATA_ROOT#g" ${DIR}/moses.ini

    # LAUNCH THE SERVER
    TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} ${DIR}/bin/moses_server_networked -config ${DIR}/moses.ini -input-file ${DATA_ROOT}/moses/testTerms -threads ${NUM_THREADS} -num-tasks 1000000 -verbose 0 &
    echo $! > server.pid
    
fi


sleep 5 # Allow server to come up

echo "Server ready. Clients can start now"


# Start the CLIENT through SSH
sudo runuser -l huawei -c "ssh -p 3322 ${USER}@xpl2.gap.upv.es \"tailbench/run_networked_network_client_from_native_to_VM.sh ${BENCH} ${N_CLIENTS} ${TBENCH_CLIENT_THREADS} ${QPS}\""

wait $(cat server.pid)


kill -9 $(cat server.pid) > /dev/null 2>&1
rm server.pid


# Copy the lats.bin files from the client
sudo runuser -l huawei -c "scp -P 3322 ${USER}@xpl2.gap.upv.es:/home/jofepre/lats_* /home/huawei/tailbench-repo/tailbench/${BENCH}"
sudo runuser -l huawei -c "scp -P 3322 ${USER}@xpl2.gap.upv.es:/home/jofepre/client_* /home/huawei/tailbench-repo/tailbench/${BENCH}"

cd /home/huawei/tailbench-repo/tailbench/${BENCH}
../utilities/agg-lats.sh
cd
