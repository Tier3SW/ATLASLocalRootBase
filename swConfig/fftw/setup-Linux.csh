#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup fftw for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_FFTW_VERSION $1
setenv ATLAS_LOCAL_FFTW_PATH ${ATLAS_LOCAL_ROOT}/fftw/${ATLAS_LOCAL_FFTW_VERSION}

insertPath PATH $ATLAS_LOCAL_FFTW_PATH/bin
if ( $?LD_LIBRARY_PATH ) then
    insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_FFTW_PATH/lib
else
    setenv LD_LIBRARY_PATH $ATLAS_LOCAL_FFTW_PATH/lib
endif
