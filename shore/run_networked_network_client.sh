#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: ./run_networked.sh N_CLIENTS TBENCH_CLIENT_THREADS CLIENT_QPS."
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

DUMMYREQS=1000000 # set this really high so MAXREQS controls execution
THREADS=1
PORT=9868

N_CLIENTS=$1
TBENCH_CLIENT_THREADS=$2
QPS=$3

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))


echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} WARMUPREQS: ${WARMUPREQS} MAXREQS: ${MAXREQS}


# Setup                                                                                                                                                                  
rm -f log scratch cmdfile db-tpcc-1 diskrw shore.conf info server.pid client.pid

TMP=$(mktemp -d --tmpdir=${SCRATCH_DIR})
ln -s $TMP scratch

mkdir scratch/log && ln -s scratch/log log
mkdir scratch/diskrw && ln -s scratch/diskrw diskrw

cp ${DATA_ROOT}/shore/db-tpcc-1 scratch/ && ln -s scratch/db-tpcc-1 db-tpcc-1
chmod 644 scratch/db-tpcc-1

cp shore-kits/run-templates/cmdfile.template cmdfile
sed -i -e "s#@NTHREADS#$THREADS#g" cmdfile
sed -i -e "s#@REQS#$DUMMYREQS#g" cmdfile

cp shore-kits/run-templates/shore.conf.template shore.conf
sed -i -e "s#@NTHREADS#$THREADS#g" shore.conf



# The system has 12 SMT cores (the first five reserved for the os and dpdk)
c1=5
c2=17
cpu_set=${c1},${c2}

for ((i=0; i<${N_CLIENTS}; i++)); do

    # LAUNCH THE CLIENT
    TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_MINSLEEPNS=100 TBENCH_ID=${i} taskset -c $cpu_set ${DIR}/shore-kits/shore_kits_client_networked -i cmdfile & 2>&1 | tee client_${i}.sal &
    
    echo $! > client_${i}.pid

    # Update the cpu_set
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
