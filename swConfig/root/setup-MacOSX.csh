#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup root for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_rootVirtVersion=$1
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )
foreach alrb_item ($alrb_tmpAr)
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
        case rVer:
	    set alrb_rootRealVersion=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	case cmt:
	    set rootCmtConfig=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	case xrdMin:
	    set alrb_rootXrdMinVer=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
        default:
	    breaksw
    endsw
end

# check if root is already available
set alrb_oldRootSys="NONEXISTINGROOTSYS"
if ( $?ROOTSYS ) then
    set alrb_result=`\echo $ROOTSYS | \grep ATLASLocalRootBase`
    if ( $? == 0 ) then
	set alrb_oldRootSys=$ROOTSYS
    endif
endif


setenv ATLAS_LOCAL_CERNROOT_VERSION $alrb_rootRealVersion
setenv ROOTSYS "${ATLAS_LOCAL_ROOT}/root/${ATLAS_LOCAL_CERNROOT_VERSION}"
        
deletePath PATH $alrb_oldRootSys/bin
insertPath PATH $ROOTSYS/bin

if ($?LD_LIBRARY_PATH) then
    deletePath LD_LIBRARY_PATH $alrb_oldRootSys/lib
    insertPath LD_LIBRARY_PATH $ROOTSYS/lib     
else
    setenv LD_LIBRARY_PATH $ROOTSYS/lib
endif
    
if ($?DYLD_LIBRARY_PATH) then
    deletePath DYLD_LIBRARY_PATH $alrb_oldRootSys/lib
    insertPath DYLD_LIBRARY_PATH $ROOTSYS/lib
else
    setenv DYLD_LIBRARY_PATH $ROOTSYS/lib
endif
    
if ($?PYTHONPATH) then
    deletePath PYTHONPATH $alrb_oldRootSys/lib
    insertPath PYTHONPATH $ROOTSYS/lib
else
    setenv PYTHONPATH $ROOTSYS/lib
endif
    
if ($?MANPATH) then
    deletePath MANPATH $alrb_oldRootSys/man
    insertPath MANPATH $ROOTSYS/man
else
    setenv MANPATH $ROOTSYS/man
endif
    
setenv rootCmtConfig $rootCmtConfig

unset alrb_oldRootSys alrb_result alrb_rc alrb_tmpAr alrb_item alrb_tmpVal alrb_rootRealVersion



