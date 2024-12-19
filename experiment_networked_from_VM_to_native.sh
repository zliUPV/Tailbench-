#!/bin/bash

BENCH=$1
CLIENTS=$2
N_THREADS=1


date=$(date '+%Y-%m-%d_%H_%M_%S')
EXP_NAME="EXP/EXP_${date}"
mkdir ${EXP_NAME}

for ((QPS_total=3000; QPS_total<20001; QPS_total=QPS_total)); do

    QPS=$(echo "scale=0; ${QPS_total}/${CLIENTS}" | bc -l)

    echo EXP $BENCH -- CLIENTS: ${CLIENTS} CLIENT_THREADS: ${N_THREADS} OVERALL_QPS: ${QPS_total} QPS_X_CLIENT: ${QPS} | tee -a ${EXP_NAME}/sal.txt

    output="${EXP_NAME}/${CLIENTS}_${N_THREADS}_${QPS_total}.txt"
    sudo ./run_networked_network_server_from_VM_to_native.sh $BENCH $CLIENTS $N_THREADS $QPS > ${output} 2>&1

    ef_qps=$(cat ${output} | grep "Effective QPS:" | awk '{print $6}' | awk 'BEGIN {s=0} {s=s+$1} END {print s}')
    timeliness=$(cat ${output} | grep "Percentatge timely requests" | awk '{print $11}' | awk 'BEGIN {s=0; n=0} {s=s+$1; n=n+1} END {print s/n}')
    latency=$(cat ${output} | grep "AGG_95th_LAT" | awk '{print $2}')
    
    echo RES ${ef_qps} ${latency} ${timeliness} | tee -a ${EXP_NAME}/sal.txt 

    QPS_total=$(echo "$QPS_total+100" | bc -l)
    
    if (( $(echo "$timeliness < 0.975" | bc -l) )); then
        echo "DISTRIBUTION BROKEN. EXPERIMENT COMPLETED!" | tee -a ${EXP_NAME}/sal.txt
        exit 0
    fi
    
    sleep 2
done
