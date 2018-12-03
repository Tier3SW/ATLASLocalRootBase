#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup AGIS for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_AGIS_VERSION $1
setenv ATLAS_LOCAL_AGIS_PATH ${ATLAS_LOCAL_ROOT}/AGIS/${ATLAS_LOCAL_AGIS_VERSION}

if ( $ALRB_RELOCATECVMFS != "YES" ) then
    source $ATLAS_LOCAL_AGIS_PATH/setup.csh
else
    source $ATLAS_LOCAL_AGIS_PATH/setup.csh.relocate
endif
