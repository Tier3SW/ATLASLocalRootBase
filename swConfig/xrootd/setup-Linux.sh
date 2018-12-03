#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup xrootd for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_XROOTD_VERSION=$1
alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/xrootd/$ATLAS_LOCAL_XROOTD_VERSION -type d -name bin`
alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

if [ ! -z $XRDSYS ]; then
    deletePath PATH "$XRDSYS/bin"
    deletePath LD_LIBRARY_PATH "$XRDSYS/lib"
    deletePath DYLD_LIBRARY_PATH "$XRDSYS/lib"
    deletePath LD_LIBRARY_PATH "$XRDSYS/lib64"
    deletePath DYLD_LIBRARY_PATH "$XRDSYS/lib64"
fi

alrb_XrootdRootFromAthena="NO"
if [[ ! -z $SITEROOT ]] && [[ ! -z $ROOTSYS ]]; then
    alrb_result=`\echo $ROOTSYS | \grep -e "$SITEROOT" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_XrootdRootFromAthena="YES"

    fi
fi

if [[ -z $ATLAS_LOCAL_CERNROOT_VERSION ]] || [[ "$alrb_XrootdRootFromAthena" = "YES" ]]; then
    export XRDSYS=$alrb_tmpVal
    insertPath PATH "$XRDSYS/bin"
    if [ -d $XRDSYS/lib ]; then 
	if [ -z $LD_LIBRARY_PATH ]; then
	    export LD_LIBRARY_PATH="$XRDSYS/lib"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib"
	fi
	if [ -z $DYLD_LIBRARY_PATH ]; then
	    export DYLD_LIBRARY_PATH="$XRDSYS/lib"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib"
	fi
    fi
    if [ -d $XRDSYS/lib64 ]; then 
	if [ -z $LD_LIBRARY_PATH ]; then
	    export LD_LIBRARY_PATH="$XRDSYS/lib64"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib64"
	fi
	if [ -z $DYLD_LIBRARY_PATH ]; then
	    export DYLD_LIBRARY_PATH="$XRDSYS/lib64"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib64"
	fi
    fi
else
    eval source $ROOTSYS/bin/setxrd.sh $alrb_tmpVal
    if [ -d $XRDSYS/lib64 ]; then 
	if [ -z $LD_LIBRARY_PATH ]; then
	    export LD_LIBRARY_PATH="$XRDSYS/lib64"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib64"
	fi
	if [ -z $DYLD_LIBRARY_PATH ]; then
	    export DYLD_LIBRARY_PATH="$XRDSYS/lib64"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib64"
	fi
    fi
    let alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh root $ATLAS_LOCAL_CERNROOT_VERSION`
    # root versions >= 6.02.10 need this include path 
    if [ $alrb_tmpVal -ge 60210 ]; then
	if [ -z $ROOT_INCLUDE_PATH ]; then
	    export ROOT_INCLUDE_PATH=$XRDSYS/include/xrootd
	else
	    insertPath ROOT_INCLUDE_PATH $XRDSYS/include/xrootd
	fi
    fi
fi

unset alrb_tmpVal alrb_result

