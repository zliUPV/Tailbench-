#ifndef OPT_ERRMSG_GEN_H
#define OPT_ERRMSG_GEN_H

/* DO NOT EDIT --- generated by ../../tools/errors.pl from opt_error.dat
                   on Mon Jan 13 14:33:56 2025 

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
static char* opt_errmsg[] = {
/* OPT_IllegalDescLine       */ "Illegal option description line",
/* OPT_IllegalClass          */ "Illegal option class name",
/* OPT_ClassTooLong          */ "Option class name too long",
/* OPT_TooManyClasses        */ "Too many option class levels",
/* OPT_Duplicate             */ "Option name is not unique",
/* OPT_NoOptionMatch         */ "Unknown option name",
/* OPT_NoClassMatch          */ "Unknown option class name",
/* OPT_Syntax                */ "Bad syntax in configuration file",
/* OPT_BadValue              */ "Bad option value",
/* OPT_NotSet                */ "A required option was not set",
	"dummy error code"
};

const opt_msg_size = 9;

#endif
