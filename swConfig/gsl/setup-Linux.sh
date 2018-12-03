#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup gsl for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_GSL_VERSION=$1
export ATLAS_LOCAL_GSL_PATH=${ATLAS_LOCAL_ROOT}/gsl/${ATLAS_LOCAL_GSL_VERSION}

insertPath PATH $ATLAS_LOCAL_GSL_PATH/bin
insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_GSL_PATH/lib
