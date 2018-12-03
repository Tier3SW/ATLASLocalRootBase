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

if ( ! $?alrb_Quiet ) then
    set alrb_Quiet=""
endif

if ( "$alrb_Quiet" != "YES" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh advanced 1 "Post"
endif

alias advancedTools 'source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/Post/advanced/setup-Linux.csh'

set alrb_AvailableToolsPost="$alrb_AvailableToolsPost advanced"

if ( "$alrb_Quiet" == "" ) then
    unset alrb_Quiet
endif

exit 0
