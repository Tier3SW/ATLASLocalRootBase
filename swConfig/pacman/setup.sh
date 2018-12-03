#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup Pacman for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_PACMAN_VERSION=$1

if [ $ALRB_RELOCATECVMFS != "YES" ]; then
    source ${ATLAS_LOCAL_ROOT}/Pacman/${ATLAS_LOCAL_PACMAN_VERSION}/setup.sh
else
    source ${ATLAS_LOCAL_ROOT}/Pacman/${ATLAS_LOCAL_PACMAN_VERSION}/setup.sh.relocate
fi


