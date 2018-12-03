#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script asetup for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_ASETUP_VERSION $1
if ( $?ATLAS_LOCAL_ASETUP_PATH ) then
    deletePath PATH $ATLAS_LOCAL_ASETUP_PATH
endif
setenv ATLAS_LOCAL_ASETUP_PATH ${ATLAS_LOCAL_ROOT}/AtlasSetup/${ATLAS_LOCAL_ASETUP_VERSION}
setenv AtlasSetup $ATLAS_LOCAL_ASETUP_PATH/AtlasSetup

set alrb_asetupVerN=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh asetup $ATLAS_LOCAL_ASETUP_VERSION`

if ( ! $?CMTUSERCONTEXT ) then
    set alrb_result=`\echo $ALRB_testPath | \grep -e ",cmtSL6-dev,"`
    if ( $? == 0 ) then
        set alrb_opts="--dev"
    else 
        set alrb_opts=""
    endif
    if ( "$alrb_Quiet" != "NO" ) then
	set alrb_opts="$alrb_opts --quiet"
    endif
    if ( -e  $ALRB_cvmfs_repo/sw/local/setup-compat.csh ) then
	source  $ALRB_cvmfs_repo/sw/local/setup-compat.csh $alrb_opts --
    else
	\echo " asetup:"
	\echo "   Warning: $ALRB_cvmfs_repo/sw/local/setup-compat.csh not found"
    endif
endif

setenv AtlasSetupSite ${ATLAS_LOCAL_ROOT}/AtlasSetup/.config/.asetup.site
if ( $alrb_asetupVerN >= 10003 ) then
    setenv AtlasSetupSiteCMake  ${ATLAS_LOCAL_ROOT}/AtlasSetup/.configCMake/.asetup.site
endif

if ( "$ALRB_RELOCATECVMFS" == "YES" ) then
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/relocateCvmfs.csh
endif
alias asetup 'source $AtlasSetup/scripts/asetup.csh'

unset alrb_asetupVerN alrb_result alrb_opts

if (( $#argv >= 2 ) && ( "$2" != "" )) then
    shift
    source $AtlasSetup/scripts/asetup.csh $* 
    exit $?    
endif
