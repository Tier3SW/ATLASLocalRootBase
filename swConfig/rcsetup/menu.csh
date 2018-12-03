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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh rcsetup 1
endif

alias changeRCSetup 'source $ATLAS_LOCAL_ROOT_BASE/swConfig/rcsetup/changeRcsetup.csh'

set alrb_AvailableTools="$alrb_AvailableTools rcsetup"
setenv ALRB_availableTools "$alrb_AvailableTools"

set alrb_tmpVal=`which rcsetup`
if (( $? != 0 ) || ( ! $?ATLAS_LOCAL_RCSETUP_VERSION )) then
    source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.csh rcsetup  -q
endif

unset  alrb_tmpVal

exit 0