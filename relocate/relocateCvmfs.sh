#!----------------------------------------------------------------------------
#!
#! relocateCvmfs.sh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs.sh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


if [ -z $ATLAS_SW_BASE ]; then
    \echo 'Error ! $ATLAS_SW_BASE not defined so not relocated ...'
    export ALRB_RELOCATECVMFS="NO"
    return 0
elif [ "$ATLAS_SW_BASE" = "/cvmfs" ]; then
    \echo 'Warning: $ATLAS_SW_BASE points to /cvmfs so not relocated ...'
    export ALRB_RELOCATECVMFS="NO"
    return 0
else
    \echo "Relocating /cvmfs to $ATLAS_SW_BASE"
fi

if [ -z $ALRB_localConfigDir ]; then
    \echo 'Error ! $ALRB_localConfigDir is not defined so not relocated ...'
    export ALRB_RELOCATECVMFS="NO"
    return 0
fi

export ALRB_RELOCATECVMFS="YES"

export VO_ATLAS_SW_DIR="$ATLAS_SW_BASE/atlas.cern.ch/repo/sw"
export ALRB_cvmfs_repo="$ATLAS_SW_BASE/atlas.cern.ch/repo"
export ALRB_cvmfs_condb_repo="$ATLAS_SW_BASE/atlas-condb.cern.ch/repo"
export ALRB_cvmfs_nightly_repo="$ATLAS_SW_BASE/atlas-nightlies.cern.ch/repo"
export ALRB_cvmfs_sft_repo="$ATLAS_SW_BASE/sft.cern.ch/lcg"

