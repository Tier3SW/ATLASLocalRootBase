#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup AGIS for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_AGIS_VERSION=$1
export ATLAS_LOCAL_AGIS_PATH=${ATLAS_LOCAL_ROOT}/AGIS/${ATLAS_LOCAL_AGIS_VERSION}

if [ $ALRB_RELOCATECVMFS != "YES" ]; then
    source $ATLAS_LOCAL_AGIS_PATH/setup.sh
else
    source $ATLAS_LOCAL_AGIS_PATH/setup.sh.relocate
fi
