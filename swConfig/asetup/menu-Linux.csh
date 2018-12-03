#!----------------------------------------------------------------------------
#!
#! menu.csh
#!
#! sets up the menu
#!
#! Usage:
#!     source menu.csh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if ( "$ALRB_cvmfs_Athena" == "" ) then
    exit
endif

if ( "$alrb_Quiet" == "NO" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh asetup 1
endif

alias changeASetup 'source $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/changeAsetup.csh'

set alrb_AvailableTools="$alrb_AvailableTools asetup"
setenv ALRB_availableTools "$alrb_AvailableTools"

set alrb_tmpVal=`which asetup`
if (( $? != 0 ) || ( ! $?ATLAS_LOCAL_ASETUP_VERSION )) then
    source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.csh asetup  -q
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createUserASetup.sh
endif

unset  alrb_tmpVal

exit 0