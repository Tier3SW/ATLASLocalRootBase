#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! getArchType.sh 
#!
#! A simple script to print out the arch type of the machine
#!
#! Usage:
#!     getArchType.sh 
#!
#! History:
#!    4May09: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ -z $ALRB_OSTYPE ]; then
    alrb_osInfo=`$ATLAS_LOCAL_ROOT_BASE/utilities/getOSType.sh`
    ALRB_OSTYPE=`\echo $alrb_osInfo | \cut -f 1 -d " "`
fi

if [ "$ALRB_OSTYPE" = "MacOSX" ]; then
    alrb_uname="x86_64-MacOS"
else
    alrb_uname=`uname -m`
fi

\echo $alrb_uname
exit 0
