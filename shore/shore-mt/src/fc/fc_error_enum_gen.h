#ifndef FC_ERROR_ENUM_GEN_H
#define FC_ERROR_ENUM_GEN_H

/* DO NOT EDIT --- generated by ../../tools/errors.pl from fc_error.dat
                   on Mon Jan 13 14:33:47 2025 

<std-header orig-src='shore' genfile='true'>

SHORE -- Scalable Heterogeneous Object REpository

Copyright (c) 1994-99 Computer Sciences Department, University of
                      Wisconsin -- Madison
All Rights Reserved.

Permission to use, copy, modify and distribute this software and its
documentation is hereby granted, provided that both the copyright
notice and this permission notice appear in all copies of the
software, derivative works or modified versions, and any portions
thereof, and that both notices appear in supporting documentation.

THE AUTHORS AND THE COMPUTER SCIENCES DEPARTMENT OF THE UNIVERSITY
OF WISCONSIN - MADISON ALLOW FREE USE OF THIS SOFTWARE IN ITS
"AS IS" CONDITION, AND THEY DISCLAIM ANY LIABILITY OF ANY KIND
FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.

This software was developed with support by the Advanced Research
Project Agency, ARPA order number 018 (formerly 8230), monitored by
the U.S. Army Research Laboratory under contract DAAB07-91-C-Q518.
Further funding for this work was provided by DARPA through
Rome Research Laboratory Contract No. F30602-97-2-0247.

*/

#include "w_defines.h"

/*  -- do not edit anything above this line --   </std-header>*/
enum {
    fcINTERNAL                = 0x10000,
    fcOS                      = 0x10001,
    fcFULL                    = 0x10002,
    fcEMPTY                   = 0x10003,
    fcOUTOFMEMORY             = 0x10004,
    fcMMAPFAILED              = 0x10005,
    fcNOTFOUND                = 0x10006,
    fcNOTIMPLEMENTED          = 0x10007,
    fcREADONLY                = 0x10008,
    fcMIXED                   = 0x10009,
    fcFOUND                   = 0x1000a,
    fcNOSUCHERROR             = 0x1000b,
    fcASSERT                  = 0x1000c,
    fcOK                      = 0x0,
    fcERRMIN                  = 0x10000,
    fcERRMAX                  = 0x1000c
};

#endif
