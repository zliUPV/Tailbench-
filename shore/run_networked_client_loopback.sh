#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVER=${1}
SERVER_PORT=${2}
WARMUP=${3}
MAXREQ=${4}
QPS=${5}
THREADS=${6}

DUMMYREQS=1000000

TBENCH_WARMUPREQS=${WARMUP} TBENCH_MAXREQS=${MAXREQ} TBENCH_SERVER=${SERVER} \
  TBENCH_SERVER_PORT=${SERVER_PORT} TBENCH_CLIENT_THREADS=${THREADS} TBENCH_QPS=${QPS} \
  TBENCH_MINSLEEPNS=10000 chrt -r 99 ./shore-kits/shore_kits_client_networked -i cmdfile &

echo "[CLIENT] : STARTED"
wait $!
echo "[CLIENT] : FINISHED"
