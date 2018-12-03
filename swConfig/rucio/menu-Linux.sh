#!----------------------------------------------------------------------------
#!
#! menu.sh
#!
#! sets up the menu
#!
#! Usage:
#!     source menu.sh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh rucio 1
fi

alias localSetupRucioClients='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh rucio'

alrb_AvailableTools="$alrb_AvailableTools rucio"

return 0
