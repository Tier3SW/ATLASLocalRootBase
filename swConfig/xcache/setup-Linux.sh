#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup xrootd local proxy cache for Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_XCACHE_VERSION=$1

export ALRB_XCACHE_SWPATH="$ATLAS_LOCAL_ROOT/xcache/$ATLAS_LOCAL_XCACHE_VERSION"

function xcache
{
    source $ALRB_XCACHE_SWPATH/do.sh $@
    return $?
}

