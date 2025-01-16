#!/bin/bash

source /home/master/Documents/Tailbenchplusplus/configs.sh

SERVER=${1}
SERVER_PORT=${2}
WARMUP=${3}
MAXREQ=${4}
QPS=${5}
THREADS=${6}

TBENCH_WARMUPREQS=${WARMUP} TBENCH_MAXREQS=${MAXREQ} TBENCH_VARQPS=0 \
  TBENCH_INIQPS=0 TBENCH_INTERVALQPS=0, TBENCH_STEPQPS=0 \
  TBENCH_SERVER=${SERVER} TBENCH_SERVER_PORT=${SERVER_PORT} TBENCH_QPS=${QPS} \
  TBENCH_CLIENT_THREADS=${THREADS} TBENCH_MINSLEEPNS=100000 \
  TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in ./xapian_networked_client &

echo "[CLIENT] : STARTED"
wait $!
echo "[CLIENT] : FINISHED"