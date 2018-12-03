#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup gcc for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_GCC_VERSION=$1

deletePath PATH $ATLAS_LOCAL_GCC_PATH
export ATLAS_LOCAL_GCC_PATH=${ATLAS_LOCAL_ROOT}/Gcc/${ATLAS_LOCAL_GCC_VERSION}
if [ $ALRB_RELOCATECVMFS != "YES" ]; then
    source ${ATLAS_LOCAL_GCC_PATH}/setup.sh
else
    source ${ATLAS_LOCAL_GCC_PATH}/setup.sh.relocate
fi

export ALRB_GPPBINPATH=`which g++ | \sed 's|\(.*\)/.*$|\1|g'`

# need this for SL6
alrb_libCVer=`getconf GNU_LIBC_VERSION | \cut -f 2 -d " "`
\echo $ATLAS_LOCAL_GCC_VERSION | \grep -e "gcc43.*slc5" >/dev/null 2>&1
alrb_rc=$?
if [[ $alrb_rc -eq 0 ]] && [[ "$alrb_libCVer" != "2.5" ]]; then
    export CXXFLAGS="$CXXFLAGS -D__USE_XOPEN2K8"
    export CPPFLAGS="$CPPFLAGS -D__USE_XOPEN2K8"
    export CFLAGS="$CFLAGS -D__USE_XOPEN2K8"
    if [ -d ${ATLAS_LOCAL_ROOT}/Gcc/.bin ]; then
	insertPath PATH "${ATLAS_LOCAL_ROOT}/Gcc/.bin"
    fi
fi

unset alrb_libCVer alrb_rc
