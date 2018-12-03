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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh printmenu 1 "Post"
endif

alias printMenu '$ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh "all"'

set alrb_AvailableToolsPost="$alrb_AvailableToolsPost printmenu"

exit 0
