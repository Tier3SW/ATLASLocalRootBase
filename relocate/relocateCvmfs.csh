#!----------------------------------------------------------------------------
#!
#! relocateCvmfs.csh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs.csh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


if ( ! $?ATLAS_SW_BASE ) then
    \echo 'Error ! $ATLAS_SW_BASE not defined so not relocated ...'
    setenv ALRB_RELOCATECVMFS "NO"
    exit 0
else if ( "$ATLAS_SW_BASE" == "/cvmfs" ) then
    \echo 'Warning: $ATLAS_SW_BASE points to /cvmfs so not relocated ...'
    setenv ALRB_RELOCATECVMFS "NO"
    exit 0
else
    \echo "Relocating /cvmfs to $ATLAS_SW_BASE"
endif

if ( ! $?ALRB_localConfigDir ) then
    \echo 'Error ! $ALRB_localConfigDir is not defined so not relocated ...'
    setenv ALRB_RELOCATECVMFS "NO"
    exit 0
endif

setenv ALRB_RELOCATECVMFS "YES"

setenv VO_ATLAS_SW_DIR $ATLAS_SW_BASE/atlas.cern.ch/repo/sw
setenv ALRB_cvmfs_repo "$ATLAS_SW_BASE/atlas.cern.ch/repo"
setenv ALRB_cvmfs_condb_repo "$ATLAS_SW_BASE/atlas-condb.cern.ch/repo"
setenv ALRB_cvmfs_nightly_repo "$ATLAS_SW_BASE/atlas-nightlies.cern.ch/repo"
setenv ALRB_cvmfs_sft_repo "$ATLAS_SW_BASE/sft.cern.ch/lcg"

