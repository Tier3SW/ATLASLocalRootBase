#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup pyami for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_PYAMI_VERSION $1

setenv PYAMI_HOME ${ATLAS_LOCAL_ROOT}/pyAmi/${ATLAS_LOCAL_PYAMI_VERSION}

source ${ATLAS_LOCAL_ROOT}/pyAmi/${ATLAS_LOCAL_PYAMI_VERSION}/setup.csh
