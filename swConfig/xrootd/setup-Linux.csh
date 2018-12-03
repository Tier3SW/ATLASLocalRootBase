#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup xrootd for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_XROOTD_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/xrootd/$ATLAS_LOCAL_XROOTD_VERSION -type d -name bin`
set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

if ( $?XRDSYS ) then
    deletePath PATH "$XRDSYS/bin"
    deletePath LD_LIBRARY_PATH "$XRDSYS/lib"
    deletePath DYLD_LIBRARY_PATH "$XRDSYS/lib"    
    deletePath LD_LIBRARY_PATH "$XRDSYS/lib64"
    deletePath DYLD_LIBRARY_PATH "$XRDSYS/lib64"    
endif

set alrb_XrootdRootFromAthena="NO"
if ( $?SITEROOT && $?ROOTSYS ) then
    set alrb_result=`\echo $ROOTSYS | \grep -e "$SITEROOT"`
    if ( $? != 0 ) then
	set alrb_XrootdRootFromAthena="YES"
    endif
endif

if (( ! $?ATLAS_LOCAL_CERNROOT_VERSION ) || ( "$alrb_XrootdRootFromAthena" == "YES" )) then
    setenv XRDSYS $alrb_tmpVal
    insertPath PATH "$XRDSYS/bin"
    if ( -d $XRDSYS/lib ) then
	if ( ! $?LD_LIBRARY_PATH ) then
	    setenv LD_LIBRARY_PATH "$XRDSYS/lib"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib"
        endif
	if ( ! $?DYLD_LIBRARY_PATH ) then
	    setenv DYLD_LIBRARY_PATH "$XRDSYS/lib"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib"
        endif
    endif
    if ( -d $XRDSYS/lib64 ) then
	if ( ! $?LD_LIBRARY_PATH ) then
	    setenv LD_LIBRARY_PATH "$XRDSYS/lib64"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib64"
        endif
	if ( ! $?DYLD_LIBRARY_PATH ) then
	    setenv DYLD_LIBRARY_PATH "$XRDSYS/lib64"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib64"
        endif
    endif
else
    source $ROOTSYS/bin/setxrd.csh $alrb_tmpVal 
    if ( -d $XRDSYS/lib64 ) then
	if ( ! $?LD_LIBRARY_PATH ) then
	    setenv LD_LIBRARY_PATH "$XRDSYS/lib64"
	else
	    insertPath LD_LIBRARY_PATH "$XRDSYS/lib64"
        endif
	if ( ! $?DYLD_LIBRARY_PATH ) then
	    setenv DYLD_LIBRARY_PATH "$XRDSYS/lib64"
	else
	    insertPath DYLD_LIBRARY_PATH "$XRDSYS/lib64"
        endif
    endif
    set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh root $ATLAS_LOCAL_CERNROOT_VERSION`
    # root versions >= 6.02.10 need this include path 
    if ( $alrb_tmpVal >= 60210 ) then
	if ( ! $?ROOT_INCLUDE_PATH ) then
	    setenv ROOT_INCLUDE_PATH $XRDSYS/include/xrootd
	else
	    insertPath ROOT_INCLUDE_PATH $XRDSYS/include/xrootd
	endif
    endif	
endif


unset alrb_tmpVal alrb_result