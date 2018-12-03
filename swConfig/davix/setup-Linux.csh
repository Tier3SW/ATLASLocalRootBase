#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup davix for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_DAVIX_VERSION $1
setenv ATLAS_LOCAL_DAVIX_PATH ${ATLAS_LOCAL_ROOT}/davix/${ATLAS_LOCAL_DAVIX_VERSION}
set alrb_tmpVal=`\find $ATLAS_LOCAL_DAVIX_PATH -type d -name bin`
set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`
setenv ALRB_DAVIX_ROOT $alrb_tmpVal

if ( -d ${ALRB_DAVIX_ROOT}/bin ) then
    insertPath PATH ${ALRB_DAVIX_ROOT}/bin
endif
if ( -d ${ALRB_DAVIX_ROOT}/lib ) then
    if ( ! $?LD_LIBRARY_PATH ) then
	setenv LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib
    else
	insertPath LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib
    endif
endif
if ( -d ${ALRB_DAVIX_ROOT}/lib64 ) then
    if ( ! $?LD_LIBRARY_PATH ) then
	setenv LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib64
    else
	insertPath LD_LIBRARY_PATH ${ALRB_DAVIX_ROOT}/lib64
    endif
endif

unset alrb_tmpVal
