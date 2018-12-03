#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup tbb for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_TBB_VERSION $1
setenv ATLAS_LOCAL_TBB_PATH ${ATLAS_LOCAL_ROOT}/tbb/${ATLAS_LOCAL_TBB_VERSION}

if ( $?LD_LIBRARY_PATH ) then
    insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_TBB_PATH/lib
else
    setenv LD_LIBRARY_PATH $ATLAS_LOCAL_TBB_PATH/lib
endif
