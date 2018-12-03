#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup EIClient for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_EICLIENT_VERSION $1

setenv EIDIR "${ATLAS_LOCAL_ROOT}/EIClient/${ATLAS_LOCAL_EICLIENT_VERSION}"
source ${ATLAS_LOCAL_ROOT}/EIClient/${ATLAS_LOCAL_EICLIENT_VERSION}/bin/setup.csh
