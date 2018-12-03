#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup fftw for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_FFTW_VERSION=$1
export ATLAS_LOCAL_FFTW_PATH=${ATLAS_LOCAL_ROOT}/fftw/${ATLAS_LOCAL_FFTW_VERSION}

insertPath PATH $ATLAS_LOCAL_FFTW_PATH/bin
insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_FFTW_PATH/lib

