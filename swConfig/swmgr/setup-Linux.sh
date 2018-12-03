#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup swmgr for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_SWMGR_VERSION=$1

insertPath PATH $ATLAS_LOCAL_ROOT_BASE/sw-mgr/$ATLAS_LOCAL_SWMGR_VERSION

