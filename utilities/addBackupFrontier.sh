#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! addBackupFrontier.sh
#!
#! Check and fix if FRONTIER_SERVER is missing backup proxies
#!
#! Usage:
#!     addBackupFrontier.sh
#!
#! History:
#!    29Sep18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# default return code is to fail
let alrb_retCode=64

if [[ ! -z $ALRB_noFrontierSetup ]] && [[ "$ALRB_noFrontierSetup" = "YES" ]]; then
    exit $alrb_retCode
fi

\echo $FRONTIER_SERVER | \grep -e "proxyurl=http://atlasbpfrontier.cern.ch:3127" 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    export FRONTIER_SERVER="$FRONTIER_SERVER(proxyurl=http://atlasbpfrontier.cern.ch:3127)"
    alrb_retCode=$?
fi

\echo $FRONTIER_SERVER | \grep -e "proxyurl=http://atlasbpfrontier.fnal.gov:3127" 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    export FRONTIER_SERVER="$FRONTIER_SERVER(proxyurl=http://atlasbpfrontier.fnal.gov:3127)"
    alrb_retCode=$?
fi

\echo $FRONTIER_SERVER
exit $alrb_retCode
