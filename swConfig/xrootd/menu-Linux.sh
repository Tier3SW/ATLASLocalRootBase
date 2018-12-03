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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh xrootd 1
fi

alias localSetupXRootD='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh xrootd'

alrb_AvailableTools="$alrb_AvailableTools xrootd"

return 0
