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

#if [ "$alrb_Quiet" = "NO" ]; then
#    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh fax 1
#fi

alias localSetupFAX='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh fax'

alrb_AvailableTools="$alrb_AvailableTools fax"

return 0
