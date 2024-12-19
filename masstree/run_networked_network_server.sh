#!/bin/bash

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

#if [ $WARMUPREQS -lt 20000 ]; then
#    WARMUPREQS=20000
#    MAXREQS=40000
#fi


echo RESULT N_CLIENTS: ${N_CLIENTS} QPS: ${QPS} WARMUPREQS: ${WARMUPREQS} MAXREQS: ${MAXREQS}


# LAUNCH THE SERVER
TBENCH_SERVER_PORT=${PORT} TBENCH_MAXREQS=${MAXREQS} TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_NCLIENTS=${N_CLIENTS} taskset -c 6,30 ${DIR}/mttest_server_networked -j${NUM_THREADS} mycsba masstree &

echo $! > server.pid


sleep 5 # Allow server to come up
echo "Server ready. Clients can start now"


# Start the CLIENT through SSH
ssh -p 3322 jofepre@xpl2.gap.upv.es "tailbench/masstree/run_networked_network_client.sh ${N_CLIENTS} ${TBENCH_CLIENT_THREADS} ${QPS}"


wait $(cat server.pid)


kill -9 $(cat server.pid) > /dev/null 2>&1
rm server.pid

# Copy the lats.bin files from the client
for ((i=0; i<${N_CLIENTS}; i++)); do
    scp -P 3322 jofepre@xpl2.gap.upv.es:lats_${i}.bin ./
    scp -P 3322 jofepre@xpl2.gap.upv.es:client_${i}.sal ./
done
ssh -p 3322 jofepre@xpl2.gap.upv.es "rm -r ./client_*; rm -r ./lats*"


# Process the results
worst_lat=0
worst_client=-1
avg_lat=0
avg_queue=0
avg_service=0
avg_timeliness=0
worst_timeliness=2

for ((i=0; i<${N_CLIENTS}; i++)); do
    lat=$(../utilities/parselats.py lats_${i}.bin | awk '{print $4}')

    queue=$(cat lats.txt | awk 'BEGIN {s=0; n=0} {s=s+$1; n=n+1} END {print s/n}')
    service=$(cat lats.txt | awk 'BEGIN {s=0; n=0} {s=s+$3; n=n+1} END {print s/n}')

    timeliness=$(cat client_${i}.sal | grep "Percentatge timely requests" | awk '{print $11}')

    echo "RESULT Client ${i} -- Latency(ms): ${lat} Queue_time(ms): ${queue} Service_time(ms): ${service} Timeliness: ${timeliness}"
    
    if (( $(echo "$lat > $worst_lat" | bc -l) )); then
        worst_client=${i}
        worst_lat=${lat}
        worst_queue=${queue}
        worst_service=${service}
    fi

    if (( $(echo "$timeliness < $worst_timeliness" | bc -l) )); then
        worst_timeliness=$timeliness
    fi

    avg_lat=$(echo "${avg_lat} + ${lat}" | bc -l)
    avg_queue=$(echo "${avg_queue} + ${queue}" | bc -l)
    avg_service=$(echo "${avg_service} + ${service}" | bc -l)
    avg_timeliness=$(echo "${avg_timeliness} + ${timeliness}" | bc -l)
done

echo RESULT WORST Client ${worst_client} Tail_latency: ${worst_lat} Queue_time: ${worst_queue} Service_time: ${worst_service} Timeliness: ${worst_timeliness}

avg_lat=$(echo "${avg_lat} / ${N_CLIENTS}" | bc -l)
avg_queue=$(echo "${avg_queue} / ${N_CLIENTS}" | bc -l)
avg_service=$(echo "${avg_service} / ${N_CLIENTS}" | bc -l)
avg_timeliness=$(echo "${avg_timeliness} / ${N_CLIENTS}" | bc -l)

echo RESULT AVG Clients Tail_latency: ${avg_lat} Queue_time: ${avg_queue} Service_time: ${avg_service} Timeliness: ${avg_timeliness}
