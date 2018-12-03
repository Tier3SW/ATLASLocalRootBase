#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup tbb for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_TBB_VERSION=$1
export ATLAS_LOCAL_TBB_PATH=${ATLAS_LOCAL_ROOT}/tbb/${ATLAS_LOCAL_TBB_VERSION}

insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_TBB_PATH/lib

