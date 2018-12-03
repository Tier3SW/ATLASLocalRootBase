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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh atlantis 1
fi

alias localSetupAtlantis='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh atlantis'

alrb_AvailableTools="$alrb_AvailableTools atlantis"

return 0
