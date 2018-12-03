#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup Pacman for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_PACMAN_VERSION $1

if ( $ALRB_RELOCATECVMFS != "YES" ) then
    source ${ATLAS_LOCAL_ROOT}/Pacman/${ATLAS_LOCAL_PACMAN_VERSION}/setup.csh
else
    source ${ATLAS_LOCAL_ROOT}/Pacman/${ATLAS_LOCAL_PACMAN_VERSION}/setup.csh.relocate
endif

