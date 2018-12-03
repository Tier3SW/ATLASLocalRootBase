#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! isGridSetup.sh
#!
#! Tells whether grid middleware is setup and type
#!
#! Usage: 
#!     isGridSetup.sh
#!       print emi or none
#!
#! History:
#!   09Feb10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


if [[ ! -z $LCG_LOCATION ]] && [[ ! -z $ATLAS_LOCAL_EMI_VERSION ]];then
    \echo "emi"
    exit 0
#elif [ ! -z $LCG_LOCATION ]; then
#    if [ -e /etc/emi-version ]; then
#	\echo "emi"
#	exit 0
#    fi
fi

\echo "none"
exit 0
