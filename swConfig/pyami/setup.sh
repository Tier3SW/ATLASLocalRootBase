#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup pyAMI for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_PYAMI_VERSION=$1

export PYAMI_HOME=${ATLAS_LOCAL_ROOT}/pyAmi/${ATLAS_LOCAL_PYAMI_VERSION}

source ${ATLAS_LOCAL_ROOT}/pyAmi/${ATLAS_LOCAL_PYAMI_VERSION}/setup.sh

