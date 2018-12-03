#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! guessFrontier.sh
#!
#! Guess the Frontier env value
#!
#! Usage:
#!     guessFrontier.sh
#!
#! History:
#!    11Jul12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# default return code is to fail
let alrb_retCode=64

if [[ ! -z $ALRB_noFrontierSetup ]] && [[ "$ALRB_noFrontierSetup" = "YES" ]]; then
    exit $alrb_retCode
fi

# first try AGIS
if [ -e $ALRB_cvmfs_repo/sw/local/bin/auto-setup ]; then
    
    alrb_cmdStr=""
    if [[ ! -z $SITE_NAME ]] || [[ ! -z $ATLAS_SITE_NAME ]]; then
	alrb_cmdStr="source $ALRB_cvmfs_repo/sw/local/bin/auto-setup"
    elif [ ! -z $PANDA_SITE_NAME ]; then
	alrb_cmdStr="source $ALRB_cvmfs_repo/sw/local/bin/auto-setup -r $PANDA_SITE_NAME"
    fi
    
    if [ "$alrb_cmdStr" != "" ]; then
	eval $alrb_cmdStr 2>&1 >> /dev/null
	let alrb_retCode=$?
	if [[ $alrb_retCode = 0 ]] && [[ ! -z $FRONTIER_SERVER ]] && [[ $FRONTIER_SERVER != "" ]]; then
	    \echo $FRONTIER_SERVER
	    exit 0
	fi
    fi
fi

# default value of FRONTIER_SERVER, if none is set, is deferred to 
#  asetup's epilog

exit $alrb_retCode
