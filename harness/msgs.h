/** $lic$
 * Copyright (C) 2016-2017 by Massachusetts Institute of Technology
 *
 * This file is part of TailBench.
 *
 * If you use this software in your research, we request that you reference the
 * TaiBench paper ("TailBench: A Benchmark Suite and Evaluation Methodology for
 * Latency-Critical Applications", Kasture and Sanchez, IISWC-2016) as the
 * source in any publications that use this software, and that you send us a
 * citation of your work.
 *
 * TailBench is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.
 */

#ifndef __MSGS_H
#define __MSGS_H

#include <stdint.h>
#include <stdlib.h>

const int MAX_REQ_BYTES = 1 << 20; // 1 MB
const int MAX_RESP_BYTES = 1 << 20; // 1 MB

enum ResponseType { RESPONSE, ROI_BEGIN, FINISH };

struct Request {
    uint64_t id;
    uint64_t genNs;
    size_t len;

    bool late;
    uint64_t startNs;           // Start of the startReq function
    uint64_t startNs_lock_ad;   // Once the thread adquires the lock
    uint64_t startNs_lock_re;   // Once the thread releases the lock
    uint64_t sentNs;            // Start of the send function
    uint64_t sentNs_lock_ad;    // Once the thread adquires the lock. THIS IS THE TIME THE REQUEST IS SENT
    uint64_t sentNs_lock_re;    // Once the data has been sent and the lock released

    char data[MAX_REQ_BYTES];
};

struct Response {
    ResponseType type;
    uint64_t id;
    uint64_t svcNs;
    size_t len;

    uint64_t recvNs;            // Time to receive the response

    //uint64_t startNs;
    //uint64_t endNs;

    char data[MAX_RESP_BYTES];
};

#endif
