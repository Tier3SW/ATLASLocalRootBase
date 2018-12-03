#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup xrootd local proxy cache for Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_XCACHE_VERSION $1

setenv ALRB_XCACHE_SWPATH "$ATLAS_LOCAL_ROOT/xcache/$ATLAS_LOCAL_XCACHE_VERSION"

alias xcache 'source $ALRB_XCACHE_SWPATH/do.csh'

