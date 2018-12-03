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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh helpme 1 "Post"
endif

alias helpMe '${ATLAS_LOCAL_ROOT_BASE}/utilities/generateHelpMe.sh'

set alrb_AvailableToolsPost="$alrb_AvailableToolsPost helpme"

exit 0
