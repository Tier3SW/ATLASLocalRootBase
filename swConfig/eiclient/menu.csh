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

if ( "$alrb_Quiet" == "NO" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh eiclient 1
endif

alias localSetupEIClient 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.csh eiclient'

set alrb_AvailableTools="$alrb_AvailableTools eiclient"

exit 0
