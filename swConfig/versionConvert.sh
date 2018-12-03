#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! versionConvert.sh
#!
#! converts version to numeric valus
#!
#! Usage:
#!     versionConvert <tool> <version to convert>
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

source $ATLAS_LOCAL_ROOT_BASE/swConfig/functions.sh
alrb_fn_versionConvert "$1" "$2"
exit $?

