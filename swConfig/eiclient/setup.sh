#!----------------------------------------------------------------------------
#!
#! setup,sh
#!
#! A simple script to setup EIClient for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_EICLIENT_VERSION=$1

export EIDIR="${ATLAS_LOCAL_ROOT}/EIClient/${ATLAS_LOCAL_EICLIENT_VERSION}"
source ${ATLAS_LOCAL_ROOT}/EIClient/${ATLAS_LOCAL_EICLIENT_VERSION}/bin/setup.sh

