#!----------------------------------------------------------------------------
#!
#! asetupEpilog.sh
#!
#! Runs things after asetup 
#!
#! Usage:
#!     asetupEpilog.sh
#!     Note: This is meant to be run by AtlasSetup (epilog)
#!
#! History:
#!    12Jul12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# set FRONTIER_SERVER if it is not set
if [[ -z $ALRB_noFrontierSetup ]] || [[ "$ALRB_noFrontierSetup" != "YES" ]]; then
    if [ -z $FRONTIER_SERVER ]; then
	export FRONTIER_SERVER="(serverurl=http://atlasfrontier-ai.cern.ch:8000/atlr)(serverurl=http://lcgft-atlas.gridpp.rl.ac.uk:3128/frontierATLAS)(serverurl=http://frontier-atlas.lcg.triumf.ca:3128/ATLAS_frontier)(serverurl=http://ccfrontier.in2p3.fr:23128/ccin2p3-AtlasFrontier)(proxyurl=http://atlasbpfrontier.cern.ch:3127)(proxyurl=http://atlasbpfrontier.fnal.gov:3127)"
    fi
fi

# if afs is setup for SITEROOT, issue a note
alrb_result=`\echo $SITEROOT | \grep '/afs/cern.ch' 2>&1`
if [ $? -eq 0 ]; then
    \echo "Note: Release is setup from /afs/cern.ch."
fi

# ASG releases are depreciated
#alrb_result=`\echo $ROOTCOREDIR | \grep '/cvmfs/atlas.cern.ch/repo/sw/ASG/'`
#if [ $? -eq 0 ]; then
#    \echo "Warning: ROOTCOREDIR points to ASG area after asetup."
#    \echo "         You are probably setting up an ASG release using asetup."
#    \echo "         This is depreciated.  Please use rcSetup instead."
#fi

# python fix
source $ATLAS_LOCAL_ROOT_BASE/swConfig/python/pythonFix-Linux.sh

unset alrb_result