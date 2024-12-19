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
SERVER_IP=192.168.10.101

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=/home/jofepre/tailbench/${BENCH}
source ${DIR}/../configs.sh

echo $BENCH

# The system has 12 SMT cores (the first five reserved for the os and dpdk)
c1=5
c2=17
cpu_set=${c1},${c2}


if [ "${BENCH}" = "shore" ]; then
    DUMMYREQS=1000000 # set this really high so MAXREQS controls execution
        
    # Setup
    cd $DIR    
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
    cd

    
elif [ "${BENCH}" = "moses" ]; then

    # Setup
    cd $DIR
    cp moses.ini.template moses.ini
    sed -i -e "s#@DATA_ROOT#$DATA_ROOT#g" moses.ini
    cd
fi


for ((i=0; i<${N_CLIENTS}; i++)); do

    if [ "${BENCH}" = "img-dnn" ]; then 
        # LAUNCH A CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} TBENCH_MNIST_DIR=${DATA_ROOT}/img-dnn/mnist taskset -c ${cpu_set} ${DIR}/img-dnn_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid

        
    elif [ "${BENCH}" = "silo" ]; then    
        # LAUNCH A CLIENT

        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} taskset -c ${cpu_set} ${DIR}/out-perf.masstree/benchmarks/dbtest_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid


    elif [ "${BENCH}" = "masstree" ]; then

        # LAUNCH A CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} taskset -c ${cpu_set} ${DIR}/mttest_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid

        
    elif [ "${BENCH}" = "shore" ]; then

        # LAUNCH THE CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} taskset -c $cpu_set ${DIR}/shore-kits/shore_kits_client_networked -i ${DIR}/cmdfile 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid


    elif [ "${BENCH}" = "moses" ]; then

        # LAUNCH THE CLIENT
        TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} ${DIR}/bin/moses_client_networked 2>&1 | tee client_${i}.sal &
        echo $! > client_${i}.pid

    fi

    
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

exit 0

