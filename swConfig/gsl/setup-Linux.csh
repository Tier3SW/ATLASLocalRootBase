#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup gsl for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_GSL_VERSION $1
setenv ATLAS_LOCAL_GSL_PATH ${ATLAS_LOCAL_ROOT}/gsl/${ATLAS_LOCAL_GSL_VERSION}

insertPath PATH $ATLAS_LOCAL_GSL_PATH/bin
if ( $?LD_LIBRARY_PATH ) then
    insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_GSL_PATH/lib
else
    setenv LD_LIBRARY_PATH $ATLAS_LOCAL_GSL_PATH/lib
endif
