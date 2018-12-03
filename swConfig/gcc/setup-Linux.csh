#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup gcc for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_GCC_VERSION $1

if ( $?ATLAS_LOCAL_GCC_PATH ) then
    deletePath PATH $ATLAS_LOCAL_GCC_PATH
endif
setenv ATLAS_LOCAL_GCC_PATH ${ATLAS_LOCAL_ROOT}/Gcc/${ATLAS_LOCAL_GCC_VERSION}
if ( $ALRB_RELOCATECVMFS != "YES" ) then
    source ${ATLAS_LOCAL_GCC_PATH}/setup.csh
else
    source ${ATLAS_LOCAL_GCC_PATH}/setup.csh.relocate
endif

setenv ALRB_GPPBINPATH `which g++ | \sed 's|\(.*\)/.*$|\1|g'`

# need this for SL6 when compiling sl5 gcc    
set alrb_libCVer=`getconf GNU_LIBC_VERSION | \cut -f 2 -d " "`
if ( ( $alrb_libCVer != "2.5" ) && ( $ATLAS_LOCAL_GCC_VERSION =~ "gcc43*slc5" ) ) then
    if ( ! $?CXXFLAGS ) then
	setenv CXXFLAGS "-D__USE_XOPEN2K8"
    else
	setenv CXXFLAGS "$CXXFLAGS -D__USE_XOPEN2K8"
    endif
    if ( ! $?CPPFLAGS ) then
	setenv CPPFLAGS "-D__USE_XOPEN2K8"
    else
	setenv CPPFLAGS "$CPPFLAGS -D__USE_XOPEN2K8"
    endif
    if ( ! $?CFLAGS ) then
	setenv CFLAGS "-D__USE_XOPEN2K8"
    else
	setenv CFLAGS "$CFLAGS -D__USE_XOPEN2K8"
    endif
    if ( -d ${ATLAS_LOCAL_ROOT}/Gcc/.bin ) then
	insertPath PATH "${ATLAS_LOCAL_ROOT}/Gcc/.bin"
    endif
endif       

unset alrb_libCVer alrb_rc
