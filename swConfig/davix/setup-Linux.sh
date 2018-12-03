#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup davix for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_DAVIX_VERSION=$1
export ATLAS_LOCAL_DAVIX_PATH=${ATLAS_LOCAL_ROOT}/davix/${ATLAS_LOCAL_DAVIX_VERSION}
alrb_tmpVal=`\find $ATLAS_LOCAL_DAVIX_PATH  -type d -name bin`
alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`
export ALRB_DAVIX_ROOT=$alrb_tmpVal

insertPath PATH ${ALRB_DAVIX_ROOT}/bin
if [ -d ${ALRB_DAVIX_ROOT}/bin ]; then
    insertPath PATH ${ALRB_DAVIX_ROOT}/bin
fi    
if [ -d ${ALRB_DAVIX_ROOT}/lib ]; then
    insertPath LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib
fi
if [ -d ${ALRB_DAVIX_ROOT}/lib64 ]; then
    insertPath LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib64
fi

unset alrb_tmpVal
