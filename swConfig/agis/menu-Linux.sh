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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh agis 1
fi

alias localSetupAGIS='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh agis'

alrb_AvailableTools="$alrb_AvailableTools agis"

return 0
