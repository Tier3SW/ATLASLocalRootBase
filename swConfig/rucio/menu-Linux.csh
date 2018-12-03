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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh rucio 1
endif

alias localSetupRucioClients 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.csh rucio'

set alrb_AvailableTools="$alrb_AvailableTools rucio"

exit 0
