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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh pod 1
fi

alias localSetupPoD='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh pod'

alrb_AvailableTools="$alrb_AvailableTools pod"

return 0
