#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup cppcheck for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_CPPCHECK_VERSION=$1
export ATLAS_LOCAL_CPPCHECK_PATH=${ATLAS_LOCAL_ROOT}/cppcheck/${ATLAS_LOCAL_CPPCHECK_VERSION}

alrb_tmpVal=`\find $ATLAS_LOCAL_CPPCHECK_PATH -type d -name wrapperBin`
CPPCHECK_HOME=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`
export CPPCHECK_HOME
insertPath PATH $CPPCHECK_HOME/wrapperBin

unset alrb_tmpVal
