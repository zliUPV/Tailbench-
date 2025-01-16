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
SERVER_IP=192.168.10.4

N_CLIENTS=$1
TBENCH_CLIENT_THREADS=$2
QPS=$3

WARMUPREQS=$((N_CLIENTS*QPS*4))
MAXREQS=$((WARMUPREQS*3))

#if [ $WARMUPREQS -lt 20000 ]; then
#    WARMUPREQS=20000
#    MAXREQS=40000
#fi


echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} 


# The system has 12 SMT cores (the first five reserved for the os and dpdk)
c1=5
c2=17
cpu_set=${c1},${c2}

for ((i=0; i<${N_CLIENTS}; i++)); do

    # LAUNCH A CLIENT
    TBENCH_SERVER=${SERVER_IP} TBENCH_SERVER_PORT=${PORT} TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100 TBENCH_CLIENT_THREADS=${TBENCH_CLIENT_THREADS} TBENCH_ID=${i} taskset -c ${cpu_set} ${DIR}/mttest_client_networked 2>&1 | tee client_${i}.sal &
    
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

exit 0
