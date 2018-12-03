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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh eiclient 1
fi

alias localSetupEIClient='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh eiclient'

alrb_AvailableTools="$alrb_AvailableTools eiclient"

return 0
